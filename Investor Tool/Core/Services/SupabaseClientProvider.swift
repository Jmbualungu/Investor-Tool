//
//  SupabaseClientProvider.swift
//  Investor Tool
//
//  Provides a singleton Supabase client configured from build settings.
//  Fails loudly if configuration is missing.
//

import Foundation
import Supabase

enum SupabaseConfigError: Error {
    case missingURL
    case missingPublishableKey
    case invalidURL
    
    var message: String {
        switch self {
        case .missingURL:
            return """
            SUPABASE_URL is not configured.
            
            Fix:
            1. Open Config/Secrets.xcconfig
            2. Set SUPABASE_URL to your Supabase project URL
            3. Clean build (Cmd+Shift+K) and rebuild (Cmd+B)
            
            See: SUPABASE_KEY_ROTATION_GUIDE.md
            """
        case .missingPublishableKey:
            return """
            SUPABASE_PUBLISHABLE_KEY is not configured.
            
            Fix:
            1. Rotate your key in Supabase Dashboard (see SUPABASE_KEY_ROTATION_GUIDE.md)
            2. Copy the new anon key
            3. Paste into Config/Secrets.xcconfig
            4. Clean build (Cmd+Shift+K) and rebuild (Cmd+B)
            """
        case .invalidURL:
            return """
            SUPABASE_URL is invalid or malformed.
            
            Expected format: https://yourproject.supabase.co
            Check Config/Secrets.xcconfig
            """
        }
    }
}

final class SupabaseClientProvider {
    
    // MARK: - Singleton
    
    static let shared = SupabaseClientProvider()
    
    // MARK: - Properties
    
    private(set) var client: SupabaseClient!
    
    // MARK: - Initialization
    
    private init() {
        do {
            self.client = try Self.createClient()
        } catch {
            // Fail loudly in debug builds
            #if DEBUG
            fatalError("""
            
            ❌ SUPABASE CONFIGURATION ERROR ❌
            
            \((error as? SupabaseConfigError)?.message ?? error.localizedDescription)
            
            """)
            #else
            // In production, log error but don't crash
            print("⚠️ Supabase configuration error: \(error)")
            #endif
        }
    }
    
    // MARK: - Configuration
    
    private static func createClient() throws -> SupabaseClient {
        // Read from Info.plist (which gets values from build settings via xcconfig)
        guard let supabaseURL = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
              !supabaseURL.isEmpty,
              !supabaseURL.contains("YOUR_PROJECT_ID") else {
            throw SupabaseConfigError.missingURL
        }
        
        guard let supabaseKey = Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String,
              !supabaseKey.isEmpty,
              !supabaseKey.contains("PASTE_YOUR_NEW_ANON_KEY_HERE"),
              !supabaseKey.contains("YOUR_ANON_KEY_HERE") else {
            throw SupabaseConfigError.missingPublishableKey
        }
        
        guard let url = URL(string: supabaseURL) else {
            throw SupabaseConfigError.invalidURL
        }
        
        return SupabaseClient(
            supabaseURL: url,
            supabaseKey: supabaseKey,
            options: SupabaseClientOptions(
                db: SupabaseClientOptions.DatabaseOptions(
                    schema: "public"
                ),
                auth: SupabaseClientOptions.AuthOptions(
                    storage: UserDefaults.standard,
                    flowType: .pkce
                )
            )
        )
    }
    
    // MARK: - Convenience Accessors
    
    var auth: AuthClient {
        client.auth
    }
    
    var database: PostgrestClient {
        client.database
    }
    
    var storage: StorageClient {
        client.storage
    }
    
    var functions: FunctionsClient {
        client.functions
    }
    
    // MARK: - Health Check
    
    func healthCheck() async throws -> Bool {
        // Simple health check: try to get current session
        do {
            _ = try await auth.session
            return true
        } catch {
            // No session is fine (user not logged in)
            // Other errors indicate configuration problems
            if error.localizedDescription.contains("Invalid API key") ||
               error.localizedDescription.contains("network") {
                throw error
            }
            return true
        }
    }
}

// MARK: - Global Convenience

extension SupabaseClient {
    static var shared: SupabaseClient {
        SupabaseClientProvider.shared.client
    }
}
