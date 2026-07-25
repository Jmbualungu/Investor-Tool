//
//  AuthDebugPanel.swift
//  Valtyde
//
//  Debug panel for auth state and deep links (DEBUG only)
//

import SwiftUI

struct AuthDebugPanel: View {
    @ObservedObject var viewModel: AuthViewModel
    let user: AuthUser?
    @State private var isExpanded: Bool = false
    
    var authStateDescription: String {
        switch viewModel.authState {
        case .loading:
            return "Loading"
        case .authenticated:
            return "Authenticated"
        case .unauthenticated:
            return "Unauthenticated"
        case .passwordRecoveryPending:
            return "Password Recovery"
        case .error:
            return "Error"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with toggle
            HStack {
                Image(systemName: "ladybug.fill")
                    .foregroundColor(.orange)
                Text("AUTH DEBUG")
                    .font(.caption2)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                }
            }
            
            if isExpanded {
                Divider()
                
                // Auth State
                VStack(alignment: .leading, spacing: 4) {
                    Text("State:")
                        .font(.caption2)
                        .fontWeight(.semibold)
                    Text(authStateDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // User Info
                if let user = user {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("User:")
                            .font(.caption2)
                            .fontWeight(.semibold)
                        Text(user.email ?? "No email")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("ID: \(user.id.uuidString.prefix(8))...")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Last Deep Link
                if let deepLink = viewModel.lastDeepLinkURL {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Last Deep Link:")
                            .font(.caption2)
                            .fontWeight(.semibold)
                        Text(deepLink)
                            .font(.caption2)
                            .foregroundColor(.blue)
                            .lineLimit(2)
                    }
                }
                
                Divider()
                
                // Actions
                VStack(spacing: 8) {
                    if user != nil {
                        Button {
                            Task {
                                await viewModel.signOut()
                            }
                        } label: {
                            Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                                .font(.caption2)
                                .frame(maxWidth: .infinity)
                                .padding(8)
                                .background(Color.red.opacity(0.1))
                                .foregroundColor(.red)
                                .cornerRadius(6)
                        }
                    }
                    
                    Button {
                        Task {
                            await viewModel.checkSession()
                        }
                    } label: {
                        Label("Refresh Session", systemImage: "arrow.clockwise")
                            .font(.caption2)
                            .frame(maxWidth: .infinity)
                            .padding(8)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(6)
                    }
                }
            }
        }
        .padding(12)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 4)
        .frame(maxWidth: 300)
    }
}

#Preview {
    VStack {
        Spacer()
        HStack {
            Spacer()
            AuthDebugPanel(
                viewModel: AuthViewModel(),
                user: AuthUser(
                    id: UUID(),
                    email: "test@example.com",
                    createdAt: Date()
                )
            )
        }
    }
    .padding()
}
