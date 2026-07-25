//
//  AuthModels.swift
//  Valtyde
//
//  Authentication models and session management
//

import Foundation
import Supabase

struct AuthUser: Identifiable, Codable {
    let id: UUID
    let email: String?
    let createdAt: Date
    
    init(from user: User) {
        self.id = user.id
        self.email = user.email
        self.createdAt = user.createdAt
    }
    
    init(id: UUID, email: String?, createdAt: Date) {
        self.id = id
        self.email = email
        self.createdAt = createdAt
    }
}

enum AuthState {
    case loading
    case authenticated(AuthUser)
    case unauthenticated
    case passwordRecoveryPending  // Deep link received, show UpdatePasswordView
    case error(String)
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case networkError
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password"
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown(let message):
            return message
        }
    }
}
