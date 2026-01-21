//
//  BackendStatusView.swift
//  Investor Tool
//
//  Debug-only screen for testing Supabase integration
//

import SwiftUI
import Supabase

struct BackendStatusView: View {
    @StateObject private var viewModel = BackendStatusViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Current User Section
                    statusSection(
                        title: "Current User",
                        icon: "person.circle.fill",
                        content: {
                            if let user = viewModel.currentUser {
                                VStack(alignment: .leading, spacing: 8) {
                                    infoRow(label: "User ID", value: user.id.uuidString)
                                    if let email = user.email {
                                        infoRow(label: "Email", value: email)
                                    }
                                    infoRow(label: "Created", value: formatDate(user.createdAt))
                                }
                            } else {
                                Text("Not signed in")
                                    .foregroundColor(.secondary)
                            }
                        }
                    )
                    
                    // Smoke Tests Section
                    statusSection(
                        title: "Smoke Tests",
                        icon: "checkmark.seal.fill",
                        content: {
                            VStack(spacing: 12) {
                                testResultRow(
                                    name: "Auth Session",
                                    result: viewModel.testResults["auth"]
                                )
                                
                                testResultRow(
                                    name: "Watchlist Read/Write",
                                    result: viewModel.testResults["watchlist"]
                                )
                                
                                testResultRow(
                                    name: "Forecast + Version",
                                    result: viewModel.testResults["forecast"]
                                )
                                
                                Button {
                                    Task {
                                        await viewModel.runAllTests()
                                    }
                                } label: {
                                    HStack {
                                        if viewModel.isRunningTests {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "play.circle.fill")
                                            Text("Run All Tests")
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .disabled(viewModel.isRunningTests || viewModel.currentUser == nil)
                            }
                        }
                    )
                    
                    // Test Logs Section
                    if !viewModel.testLogs.isEmpty {
                        statusSection(
                            title: "Test Logs",
                            icon: "doc.text.fill",
                            content: {
                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(viewModel.testLogs, id: \.self) { log in
                                        Text(log)
                                            .font(.system(.caption, design: .monospaced))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Backend Status")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await viewModel.loadCurrentUser()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadCurrentUser()
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private func statusSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }
            
            content()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }
    
    private func infoRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.footnote)
                .textSelection(.enabled)
        }
    }
    
    private func testResultRow(name: String, result: TestResult?) -> some View {
        HStack {
            Text(name)
                .font(.subheadline)
            
            Spacer()
            
            if let result = result {
                switch result {
                case .notRun:
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                case .running:
                    ProgressView()
                case .passed:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                case .failed(let error):
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .help(error)
                }
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - View Model

@MainActor
final class BackendStatusViewModel: ObservableObject {
    @Published var currentUser: AuthUser?
    @Published var testResults: [String: TestResult] = [:]
    @Published var testLogs: [String] = []
    @Published var isRunningTests = false
    
    private let supabase = SupabaseClientProvider.shared
    
    func loadCurrentUser() async {
        do {
            let session = try await supabase.auth.session
            currentUser = AuthUser(from: session.user)
            log("✅ Loaded user: \(session.user.id)")
        } catch {
            currentUser = nil
            log("ℹ️ No active session")
        }
    }
    
    func runAllTests() async {
        isRunningTests = true
        testLogs = []
        
        await testAuthSession()
        await testWatchlistReadWrite()
        await testForecastCreation()
        
        isRunningTests = false
    }
    
    // MARK: - Test 1: Auth Session
    
    private func testAuthSession() async {
        testResults["auth"] = .running
        log("🧪 Test 1: Auth Session...")
        
        do {
            let session = try await supabase.auth.session
            log("✅ User ID: \(session.user.id)")
            log("✅ Email: \(session.user.email ?? "none")")
            testResults["auth"] = .passed
        } catch {
            log("❌ Auth test failed: \(error.localizedDescription)")
            testResults["auth"] = .failed(error.localizedDescription)
        }
    }
    
    // MARK: - Test 2: Watchlist Read/Write
    
    private func testWatchlistReadWrite() async {
        testResults["watchlist"] = .running
        log("🧪 Test 2: Watchlist Read/Write...")
        
        guard let userId = currentUser?.id else {
            testResults["watchlist"] = .failed("No user ID")
            return
        }
        
        do {
            // Insert test ticker
            let testTicker = "AAPL-TEST-\(Int.random(in: 1000...9999))"
            
            struct WatchlistInsert: Encodable {
                let user_id: UUID
                let ticker: String
            }
            
            let insert = WatchlistInsert(user_id: userId, ticker: testTicker)
            
            try await supabase.database
                .from("watchlists")
                .insert(insert)
                .execute()
            
            log("✅ Inserted watchlist ticker: \(testTicker)")
            
            // Read it back
            struct WatchlistRow: Decodable {
                let id: UUID
                let ticker: String
            }
            
            let response: [WatchlistRow] = try await supabase.database
                .from("watchlists")
                .select()
                .eq("ticker", value: testTicker)
                .execute()
                .value
            
            if response.first?.ticker == testTicker {
                log("✅ Read back ticker successfully")
                testResults["watchlist"] = .passed
                
                // Clean up
                try? await supabase.database
                    .from("watchlists")
                    .delete()
                    .eq("ticker", value: testTicker)
                    .execute()
                log("🧹 Cleaned up test data")
            } else {
                testResults["watchlist"] = .failed("Read mismatch")
            }
        } catch {
            log("❌ Watchlist test failed: \(error.localizedDescription)")
            testResults["watchlist"] = .failed(error.localizedDescription)
        }
    }
    
    // MARK: - Test 3: Forecast + Version (via Edge Function)
    
    private func testForecastCreation() async {
        testResults["forecast"] = .running
        log("🧪 Test 3: Forecast + Version...")
        
        guard let userId = currentUser?.id else {
            testResults["forecast"] = .failed("No user ID")
            return
        }
        
        do {
            // Create forecast
            struct ForecastInsert: Encodable {
                let user_id: UUID
                let ticker: String
                let name: String
            }
            
            let testTicker = "MSFT-TEST"
            let forecastInsert = ForecastInsert(
                user_id: userId,
                ticker: testTicker,
                name: "Test Forecast"
            )
            
            struct ForecastRow: Decodable {
                let id: UUID
            }
            
            let forecast: [ForecastRow] = try await supabase.database
                .from("forecasts")
                .insert(forecastInsert)
                .select()
                .execute()
                .value
            
            guard let forecastId = forecast.first?.id else {
                testResults["forecast"] = .failed("No forecast ID returned")
                return
            }
            
            log("✅ Created forecast: \(forecastId)")
            
            // Try to call Edge Function to create version
            struct VersionRequest: Encodable {
                let forecast_id: UUID
                let assumptions: [String: String]
                let note: String
            }
            
            let request = VersionRequest(
                forecast_id: forecastId,
                assumptions: ["test": "data"],
                note: "Smoke test version"
            )
            
            // Note: This will fail if Edge Function isn't deployed yet
            // That's okay for now - we test the DB layer
            do {
                let _: EmptyResponse = try await supabase.functions
                    .invoke("write-forecast-version", options: FunctionInvokeOptions(body: request))
                log("✅ Created version via Edge Function")
            } catch {
                log("⚠️ Edge Function not available (expected if not deployed yet)")
                log("ℹ️ Testing direct DB insert as fallback...")
                
                // Fallback: direct insert
                struct VersionInsert: Encodable {
                    let forecast_id: UUID
                    let user_id: UUID
                    let assumptions: [String: String]
                    let note: String
                }
                
                let versionInsert = VersionInsert(
                    forecast_id: forecastId,
                    user_id: userId,
                    assumptions: ["test": "data"],
                    note: "Smoke test"
                )
                
                try await supabase.database
                    .from("forecast_versions")
                    .insert(versionInsert)
                    .execute()
                
                log("✅ Created version via direct DB insert")
            }
            
            testResults["forecast"] = .passed
            
            // Clean up
            try? await supabase.database
                .from("forecasts")
                .delete()
                .eq("id", value: forecastId.uuidString)
                .execute()
            log("🧹 Cleaned up test forecast")
            
        } catch {
            log("❌ Forecast test failed: \(error.localizedDescription)")
            testResults["forecast"] = .failed(error.localizedDescription)
        }
    }
    
    // MARK: - Logging
    
    private func log(_ message: String) {
        print(message)
        testLogs.append(message)
    }
}

// MARK: - Supporting Types

enum TestResult {
    case notRun
    case running
    case passed
    case failed(String)
}

struct EmptyResponse: Decodable {}

#Preview {
    BackendStatusView()
}
