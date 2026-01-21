//
//  AuthViewModel.swift
//  Investor Tool
//
//  Handles authentication logic
//

import Foundation
import Supabase

@MainActor
final class AuthViewModel: ObservableObject {
    
    @Published var authState: AuthState = .loading
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseClientProvider.shared
    
    init() {
        Task {
            await checkSession()
        }
    }
    
    // MARK: - Session Management
    
    func checkSession() async {
        authState = .loading
        
        do {
            let session = try await supabase.auth.session
            let authUser = AuthUser(from: session.user)
            authState = .authenticated(authUser)
        } catch {
            authState = .unauthenticated
        }
    }
    
    // MARK: - Sign In
    
    func signIn() async {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
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
}
