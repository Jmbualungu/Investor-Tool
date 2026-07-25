//
//  UpdatePasswordView.swift
//  Valtyde
//
//  OPTION A: Set new password after deep link opens app
//

import SwiftUI

struct UpdatePasswordView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var isSuccess: Bool = false
    
    var passwordsMatch: Bool {
        !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword == confirmPassword
    }
    
    var passwordValid: Bool {
        newPassword.count >= 6
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Set New Password")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose a strong password for your account")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Spacer()
                
                if isSuccess {
                    // Success State
                    VStack(spacing: 16) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Password Updated!")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("Your password has been successfully updated. You're now signed in.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                } else {
                    // Input State
                    VStack(spacing: 16) {
                        // New Password Field
                        HStack {
                            if showPassword {
                                TextField("New Password", text: $newPassword)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("New Password", text: $newPassword)
                            }
                            
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // Confirm Password Field
                        HStack {
                            if showPassword {
                                TextField("Confirm Password", text: $confirmPassword)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        
                        // Password Requirements
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: passwordValid ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(passwordValid ? .green : .secondary)
                                Text("At least 6 characters")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(passwordsMatch ? .green : .secondary)
                                Text("Passwords match")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
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
                            let success = await viewModel.updatePassword(newPassword: newPassword)
                            if success {
                                withAnimation {
                                    isSuccess = true
                                }
                                
                                // Auto-dismiss after showing success
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    // State will transition to .authenticated via auth listener
                                }
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Update Password")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background((passwordsMatch && passwordValid) ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    .disabled(viewModel.isLoading || !passwordsMatch || !passwordValid)
                }
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    UpdatePasswordView(viewModel: AuthViewModel())
}
