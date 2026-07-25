//
//  ResetPasswordView.swift
//  Valtyde
//
//  Request password reset email
//

import SwiftUI

struct ResetPasswordView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var email: String = ""
    @State private var isSuccess: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enter your email and we'll send you a link to reset your password")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)
                
                Spacer()
                
                if isSuccess {
                    // Success State
                    VStack(spacing: 16) {
                        Image(systemName: "envelope.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Email Sent!")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Check your email for a password reset link. Open it on this device to set a new password.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 16)
                    }
                } else {
                    // Input State
                    VStack(spacing: 16) {
                        TextField("Email", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                        
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 32)
                    
                    Button {
                        Task {
                            let success = await viewModel.sendPasswordReset(email: email)
                            if success {
                                withAnimation {
                                    isSuccess = true
                                }
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Send Reset Link")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(email.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    .disabled(viewModel.isLoading || email.isEmpty)
                }
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !isSuccess {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ResetPasswordView(viewModel: AuthViewModel())
}
