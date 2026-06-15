//
//  SettingsView.swift
//  Investor Tool
//
//  Settings screen with Legal section for Privacy Policy and Terms
//

import SwiftUI
import SafariServices

struct SettingsView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var showingSafari = false
    @State private var safariURL: URL?
    @State private var showDeleteConfirm = false
    @State private var isDeleting = false
    @State private var deleteError: String?

    private let privacyURL = "https://jmbualungu.github.io/Investor-Tool/privacy.html"
    private let termsURL = "https://jmbualungu.github.io/Investor-Tool/terms.html"

    private var accountEmail: String? {
        if case .authenticated(let user) = authViewModel.authState { return user.email }
        return nil
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Account Section
                Section {
                    HStack {
                        Label("Signed in as", systemImage: "person.crop.circle")
                            .foregroundColor(DSColors.textPrimary)
                        Spacer()
                        Text(accountEmail ?? "Guest")
                            .foregroundColor(DSColors.textSecondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }

                    Button {
                        Task { await authViewModel.signOut() }
                    } label: {
                        Label(accountEmail == nil ? "Exit guest mode" : "Sign Out",
                              systemImage: "rectangle.portrait.and.arrow.right")
                            .foregroundColor(DSColors.textPrimary)
                    }

                    if accountEmail != nil {
                        Button(role: .destructive) {
                            showDeleteConfirm = true
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                        .disabled(isDeleting)
                    }
                } header: {
                    Text("Account")
                } footer: {
                    if let deleteError {
                        Text(deleteError).font(DSTypography.caption).foregroundColor(.red)
                    } else if accountEmail == nil {
                        Text("You're using Presage without an account. Sign in to sync your forecasts across devices.")
                            .font(DSTypography.caption)
                    } else {
                        Text("Deleting your account permanently removes your data. This cannot be undone.")
                            .font(DSTypography.caption)
                    }
                }

                // MARK: - Legal Section
                Section {
                    Button {
                        openPrivacyPolicy()
                    } label: {
                        HStack {
                            Label("Privacy Policy", systemImage: "hand.raised.fill")
                                .foregroundColor(DSColors.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 16))
                                .foregroundColor(DSColors.textTertiary)
                        }
                    }
                    
                    Button {
                        openTermsOfService()
                    } label: {
                        HStack {
                            Label("Terms of Service", systemImage: "doc.text.fill")
                                .foregroundColor(DSColors.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 16))
                                .foregroundColor(DSColors.textTertiary)
                        }
                    }
                } header: {
                    Text("Legal")
                } footer: {
                    Text("Review our legal policies and terms of service.")
                        .font(DSTypography.caption)
                }
                
                // MARK: - App Info Section
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(DSColors.textPrimary)
                        
                        Spacer()
                        
                        Text(appVersion)
                            .foregroundColor(DSColors.textSecondary)
                    }
                    
                    HStack {
                        Text("Build")
                            .foregroundColor(DSColors.textPrimary)
                        
                        Spacer()
                        
                        Text(buildNumber)
                            .foregroundColor(DSColors.textSecondary)
                    }
                } header: {
                    Text("About")
                } footer: {
                    Text("Presage provides financial forecasting tools for educational purposes only. Market data shown is illustrative. Not financial advice.")
                        .font(DSTypography.caption)
                }
                
                // MARK: - Support Section
                Section {
                    Button {
                        openSupportEmail()
                    } label: {
                        HStack {
                            Label("Contact Support", systemImage: "envelope.fill")
                                .foregroundColor(DSColors.textPrimary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.right.square")
                                .font(.system(size: 16))
                                .foregroundColor(DSColors.textTertiary)
                        }
                    }
                } header: {
                    Text("Support")
                } footer: {
                    Text("Questions or feedback? We'd love to hear from you.")
                        .font(DSTypography.caption)
                }
            }
            .navigationTitle("Settings")
            .listStyle(.insetGrouped)
            .sheet(isPresented: $showingSafari) {
                if let url = safariURL {
                    SafariView(url: url)
                }
            }
            .confirmationDialog("Delete your account?",
                                isPresented: $showDeleteConfirm,
                                titleVisibility: .visible) {
                Button("Delete Account", role: .destructive) {
                    Task {
                        isDeleting = true
                        deleteError = nil
                        let ok = await authViewModel.deleteAccount()
                        isDeleting = false
                        if !ok { deleteError = authViewModel.errorMessage ?? "Could not delete account. Please try again." }
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This permanently deletes your account and all associated data. This cannot be undone.")
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - Actions
    
    private func openPrivacyPolicy() {
        if let url = URL(string: privacyURL) {
            safariURL = url
            showingSafari = true
        }
    }

    private func openTermsOfService() {
        if let url = URL(string: termsURL) {
            safariURL = url
            showingSafari = true
        }
    }

    private func openSupportEmail() {
        if let url = URL(string: "mailto:jmbualungu@gmail.com") {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Safari View Wrapper

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    SettingsView()
}
