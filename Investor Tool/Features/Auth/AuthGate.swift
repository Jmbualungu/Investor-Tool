//
//  AuthGate.swift
//  Investor Tool
//
//  Routes between auth states: signed out -> LoginView, signed in -> MainApp, password recovery -> UpdatePasswordView
//

import SwiftUI

struct AuthGate<MainAppView: View>: View {
    @ObservedObject var viewModel: AuthViewModel
    let mainApp: () -> MainAppView
    
    var body: some View {
        Group {
            switch viewModel.authState {
            case .loading:
                // Loading state — fill frame, center content
                ZStack {
                    VStack {
                        ProgressView()
                        Text("Loading...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            case .authenticated(let user):
                // User is signed in - show main app
                mainApp()
                    .environmentObject(viewModel)
                    .overlay(alignment: .topTrailing) {
                        #if DEBUG
                        AuthDebugPanel(viewModel: viewModel, user: user)
                            .padding()
                        #endif
                    }
                
            case .unauthenticated:
                // User needs to sign in
                LoginView(viewModel: viewModel)
                    .overlay(alignment: .topTrailing) {
                        #if DEBUG
                        AuthDebugPanel(viewModel: viewModel, user: nil)
                            .padding()
                        #endif
                    }
                
            case .passwordRecoveryPending:
                // User opened password reset link - show update password view
                UpdatePasswordView(viewModel: viewModel)
                    .overlay(alignment: .topTrailing) {
                        #if DEBUG
                        AuthDebugPanel(viewModel: viewModel, user: nil)
                            .padding()
                        #endif
                    }
                
            case .error(let message):
                // Error state (e.g. Supabase not configured) — fill frame, center content
                ZStack {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        
                        Text("Authentication Error")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(message)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button {
                            Task {
                                await viewModel.checkSession()
                            }
                        } label: {
                            Text("Retry")
                                .fontWeight(.semibold)
                                .frame(maxWidth: 200)
                                .frame(height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        #if DEBUG
                        Button {
                            viewModel.devSkipAuth()
                        } label: {
                            HStack(spacing: 6) {
                                Text("Skip for now (Debug)")
                                    .fontWeight(.medium)
                                Text("DEV")
                                    .font(.caption2.bold())
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .clipShape(Capsule())
                            }
                            .foregroundColor(.orange)
                        }
                        .buttonStyle(.bordered)
                        .padding(.top, 8)
                        #endif
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    AuthGate(viewModel: AuthViewModel()) {
        Text("Main App Content")
    }
}
