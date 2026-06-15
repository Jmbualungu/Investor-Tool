//
//  AuthViewModel.swift
//  Investor Tool
//
//  Handles authentication logic
//

import Combine
import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var authState: AuthState = .loading
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var lastDeepLinkURL: String?  // For debugging
    
    private var authStateChangeTask: Task<Void, Never>?
    
    private var supabase: SupabaseClient? { SupabaseClientProvider.shared.client }
    
    private static let notConfiguredMessage = "Supabase not configured. Check Config/Secrets.xcconfig and rebuild, or use Skip for now (Debug)."
    
    init() {
        Task {
            await checkSession()
            await setupAuthStateListener()
        }
    }
    
    deinit {
        authStateChangeTask?.cancel()
    }
    
    // MARK: - Auth State Listener
    
    private func setupAuthStateListener() async {
        guard let supabase = supabase else { return }
        authStateChangeTask = Task { @MainActor in
            for await state in supabase.auth.authStateChanges {
                print("🔐 Auth state changed: \(state.event)")
                
                switch state.event {
                case .signedIn, .tokenRefreshed, .userUpdated:
                    if let user = state.session?.user {
                        let authUser = AuthUser(from: user)
                        self.authState = .authenticated(authUser)
                    }
                case .signedOut:
                    self.authState = .unauthenticated
                case .passwordRecovery:
                    // This indicates a password recovery deep link was processed
                    self.authState = .passwordRecoveryPending
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Session Management
    
    func checkSession() async {
        authState = .loading

        // Guest mode: user previously chose to continue without an account.
        // Honor it before touching the network so the app opens instantly.
        if Self.isGuestPersisted {
            authState = .authenticated(Self.guestUser)
            return
        }

        guard let supabase = supabase else {
            authState = .error(Self.notConfiguredMessage)
            return
        }
        do {
            let session = try await supabase.auth.session
            let authUser = AuthUser(from: session.user)
            authState = .authenticated(authUser)
        } catch {
            authState = .unauthenticated
        }
    }

    // MARK: - Guest Mode (no account)

    private static let guestDefaultsKey = "isGuestMode"
    private static let guestIDDefaultsKey = "guestUserID"

    static var isGuestPersisted: Bool {
        UserDefaults.standard.bool(forKey: guestDefaultsKey)
    }

    /// A stable synthetic user for account-free use.
    static var guestUser: AuthUser {
        let id: UUID
        if let stored = UserDefaults.standard.string(forKey: guestIDDefaultsKey),
           let uuid = UUID(uuidString: stored) {
            id = uuid
        } else {
            id = UUID()
            UserDefaults.standard.set(id.uuidString, forKey: guestIDDefaultsKey)
        }
        return AuthUser(id: id, email: nil, createdAt: Date())
    }

    /// Enter the app without creating an account. Persists across launches
    /// until the user signs into a real account.
    func continueAsGuest() {
        UserDefaults.standard.set(true, forKey: Self.guestDefaultsKey)
        authState = .authenticated(Self.guestUser)
    }

    // MARK: - Account Deletion (App Store requirement)

    /// Permanently deletes the user's account. Guests simply exit guest mode.
    /// Real accounts are removed server-side via the `delete-account` edge function.
    @discardableResult
    func deleteAccount() async -> Bool {
        // Guest: nothing server-side to delete; just leave guest mode.
        if Self.isGuestPersisted {
            UserDefaults.standard.set(false, forKey: Self.guestDefaultsKey)
            authState = .unauthenticated
            return true
        }

        guard let supabase = supabase else {
            errorMessage = Self.notConfiguredMessage
            return false
        }
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            // Edge function uses the caller's JWT + service role to delete the auth user and data.
            try await supabase.functions.invoke("delete-account")
            try? await supabase.auth.signOut()
            UserDefaults.standard.set(false, forKey: Self.guestDefaultsKey)
            authState = .unauthenticated
            email = ""
            password = ""
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // MARK: - Sign In
    
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        guard let supabase = supabase else {
            errorMessage = Self.notConfiguredMessage
            return
        }
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            UserDefaults.standard.set(false, forKey: Self.guestDefaultsKey)
            let authUser = AuthUser(from: session.user)
            authState = .authenticated(authUser)
        } catch {
            errorMessage = error.localizedDescription
            authState = .unauthenticated
        }
        
        isLoading = false
    }
    
    // MARK: - Sign Up
    
    func signUp() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return
        }
        guard let supabase = supabase else {
            errorMessage = Self.notConfiguredMessage
            return
        }
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            // Check if email confirmation is required
            if session.user.emailConfirmedAt == nil {
                errorMessage = "Please check your email to confirm your account"
                authState = .unauthenticated
            } else {
                UserDefaults.standard.set(false, forKey: Self.guestDefaultsKey)
                let authUser = AuthUser(from: session.user)
                authState = .authenticated(authUser)
            }
        } catch {
            errorMessage = error.localizedDescription
            authState = .unauthenticated
        }

        isLoading = false
    }

    // MARK: - Sign Out
    
    func signOut() async {
        // Leaving guest mode returns the user to the sign-in screen.
        if Self.isGuestPersisted {
            UserDefaults.standard.set(false, forKey: Self.guestDefaultsKey)
            authState = .unauthenticated
            email = ""
            password = ""
            return
        }

        #if DEBUG
        if isDevBypass {
            isDevBypass = false
            authState = .unauthenticated
            email = ""
            password = ""
            return
        }
        #endif

        guard let supabase = supabase else {
            authState = .unauthenticated
            email = ""
            password = ""
            return
        }
        isLoading = true
        
        do {
            try await supabase.auth.signOut()
            authState = .unauthenticated
            email = ""
            password = ""
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Password Reset
    
    func sendPasswordReset(email: String) async -> Bool {
        guard !email.isEmpty else {
            errorMessage = "Please enter your email"
            return false
        }
        guard let supabase = supabase else {
            errorMessage = Self.notConfiguredMessage
            return false
        }
        isLoading = true
        errorMessage = nil
        
        do {
            // CRITICAL: Must include redirectTo with augur:// scheme
            try await supabase.auth.resetPasswordForEmail(
                email,
                redirectTo: URL(string: "augur://auth-callback")
            )
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    func updatePassword(newPassword: String) async -> Bool {
        guard !newPassword.isEmpty else {
            errorMessage = "Please enter a new password"
            return false
        }
        guard newPassword.count >= 6 else {
            errorMessage = "Password must be at least 6 characters"
            return false
        }
        guard let supabase = supabase else {
            errorMessage = Self.notConfiguredMessage
            return false
        }
        isLoading = true
        errorMessage = nil
        
        do {
            // Update password for current recovery session
            let response = try await supabase.auth.update(
                user: UserAttributes(
                    password: newPassword
                )
            )
            
            // Password updated successfully (update returns User directly)
            let authUser = AuthUser(from: response)
            authState = .authenticated(authUser)
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Debug-Only Auth Bypass (compiled out in Release)
    
    #if DEBUG
    private var isDevBypass = false
    
    /// Sets auth state to "authenticated" with a synthetic user. No Supabase session.
    /// Call only from DEBUG-only UI. Compiled out in Release.
    func devSkipAuth() {
        assert(true, "devSkipAuth is DEBUG-only")
        isDevBypass = true
        let devUser = AuthUser(
            id: UUID(),
            email: "dev-bypass@local",
            createdAt: Date()
        )
        authState = .authenticated(devUser)
    }
    
    /// Credentials from createTestAccount, for display in UI.
    @Published var devTestAccountCredentials: (email: String, password: String)?
    
    /// Creates a test Supabase account, signs in if no confirmation required, and exposes credentials.
    func createTestAccount() async {
        guard let supabase = supabase else {
            errorMessage = Self.notConfiguredMessage
            return
        }
        let email = "forecastai.test+\(UUID().uuidString)@example.com"
        let password = "TestPassw0rd!234"
        self.email = email
        self.password = password
        devTestAccountCredentials = (email, password)
        print("🧪 [DEV] Create Test Account — email: \(email), password: \(password)")
        
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signUp(email: email, password: password)
            if session.user.emailConfirmedAt != nil {
                let authUser = AuthUser(from: session.user)
                authState = .authenticated(authUser)
            } else {
                errorMessage = "Check email to confirm, or use Skip for now (Debug)."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    #endif
    
    // MARK: - Deep Link Handling
    
    func handleOpenURL(_ url: URL) async {
        print("🔗 Deep link received: \(url.absoluteString)")
        lastDeepLinkURL = url.absoluteString
        guard let supabase = supabase else {
            errorMessage = Self.notConfiguredMessage
            return
        }
        // Pass URL to Supabase auth to process the session exchange
        do {
            // The Supabase SDK will handle the session exchange and trigger auth state changes
            _ = try await supabase.auth.session(from: url)
            print("✅ Deep link session exchange successful")
        } catch {
            print("❌ Deep link error: \(error.localizedDescription)")
            errorMessage = "Failed to process authentication link: \(error.localizedDescription)"
        }
    }
}
