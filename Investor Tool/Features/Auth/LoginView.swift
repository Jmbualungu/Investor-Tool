//
//  LoginView.swift
//  Investor Tool
//
//  Login/Sign Up view with Forgot Password link
//

import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var showResetPassword = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Logo/Branding
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)

                    Text("Presage")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(isSignUp ? "Create your account" : "Welcome back")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Input Fields
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal, 32)
                
                // Action Button
                Button {
                    Task {
                        if isSignUp {
                            await viewModel.signUp()
                        } else {
                            await viewModel.signIn()
                        }
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                    } else {
                        Text(isSignUp ? "Sign Up" : "Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 32)
                .disabled(viewModel.isLoading)
                
                // Toggle Sign In/Sign Up (link-style)
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isSignUp.toggle()
                        viewModel.errorMessage = nil
                    }
                } label: {
                    Text(isSignUp ? "Already have an account? Sign in" : "Don't have an account? Sign up")
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                
                // Forgot Password (only show when in Sign In mode)
                if !isSignUp {
                    Button {
                        showResetPassword = true
                    } label: {
                        Text("Forgot Password?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }

                // Account-free entry
                Button {
                    viewModel.continueAsGuest()
                } label: {
                    Text("Continue without an account")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 32)
                .padding(.top, 4)

                #if DEBUG
                // Debug-only: Skip auth bypass + Create Test Account
                VStack(spacing: 12) {
                    if let creds = viewModel.devTestAccountCredentials {
                        VStack(spacing: 4) {
                            Text("Test account created (copy from console)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(creds.email)
                                .font(.caption)
                                .lineLimit(1)
                                .truncationMode(.middle)
                            Text("Password: \(creds.password)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .padding(8)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(8)
                    }
                    Button {
                        viewModel.devSkipAuth()
                    } label: {
                        HStack(spacing: 6) {
                            Text("Skip for now (Debug)")
                                .font(.subheadline.weight(.medium))
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
                    Button {
                        Task { await viewModel.createTestAccount() }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Create Test Account (Debug)")
                                .font(.subheadline.weight(.medium))
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
                    .disabled(viewModel.isLoading)
                }
                .padding(.top, 8)
                #endif
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarHidden(true)
            .sheet(isPresented: $showResetPassword) {
                ResetPasswordView(viewModel: viewModel)
            }
        }
    }
}

#Preview {
    LoginView(viewModel: AuthViewModel())
}
