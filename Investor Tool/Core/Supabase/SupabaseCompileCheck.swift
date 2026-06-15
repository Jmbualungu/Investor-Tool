//
//  SupabaseCompileCheck.swift
//  Investor Tool
//
//  DEBUG ONLY: Ensures Supabase module compiles and links correctly
//

#if DEBUG
import Foundation
import Supabase

/// Compile-time check to ensure Supabase module is properly linked
@MainActor
final class SupabaseCompileCheck {
    
    /// Verifies Supabase client is accessible
    static func verify() {
        _ = SupabaseClientProvider.shared.client
        print("✅ Supabase module linked successfully")
    }
    
    /// Test that basic Supabase types are available
    static func checkTypes() {
        let _: SupabaseClient? = nil
        let _: AuthClient? = nil
        let _: FunctionsClient? = nil
        print("✅ Supabase types available")
    }
}
#endif
