import SwiftUI

struct SearchOverlayView: View {
    @ObservedObject var viewModel: BrowseViewModel
    @EnvironmentObject private var watchlistStore: WatchlistStore
    @EnvironmentObject private var forecastStore: ForecastStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastIcon = ""
    
    var body: some View {
        ZStack {
            // Semi-transparent background with blur
            DSColors.background.opacity(0.95)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeOut(duration: 0.2)) {
                        viewModel.clearSearch()
                    }
                }
            
            VStack(spacing: 0) {
                // Keep header and search bar visible
                Color.clear
                    .frame(height: 120)
                
                // Results list with fade + slide-in animation
                ScrollView {
                    LazyVStack(spacing: 0) {
                        if viewModel.searchQuery.isEmpty && !viewModel.recentSearches.isEmpty {
                            recentSearchesView
                                .transition(.opacity)
                        } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                            emptyStateView
                                .transition(.opacity.combined(with: .scale(scale: 0.95)))
                        } else if !viewModel.searchResults.isEmpty {
                            ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, result in
                                searchResultRow(result)
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .move(edge: .top)),
                                        removal: .opacity
                                    ))
                                    .animation(.easeOut(duration: 0.2).delay(Double(index) * 0.03), value: viewModel.searchResults)
                                
                                if result != viewModel.searchResults.last {
                                    Divider()
                                        .background(DSColors.border.opacity(0.5))
                                        .padding(.leading, DSSpacing.l)
                                }
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .background(DSColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(DSColors.border.opacity(0.5), lineWidth: 0.5)
                )
                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                .padding(.horizontal, DSSpacing.l)
                
                Spacer()
            }
            
            // Toast notification
            VStack {
                if showToast {
                    HStack(spacing: 10) {
                        Image(systemName: toastIcon)
                            .font(.system(size: 14, weight: .semibold))
                        Text(toastMessage)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.black.opacity(0.85))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(.top, 60)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
    
    // MARK: - Search Result Row
    
    private func searchResultRow(_ result: TickerSearchResult) -> some View {
        HStack(spacing: 12) {
            // Ticker info (tappable to navigate)
            NavigationLink(destination: TickerDetailView(ticker: Ticker(symbol: result.ticker, name: result.companyName))) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 3) {
                        // Ticker: primary, semibold
                        Text(result.ticker)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                        
                        // Company name: secondary, muted
                        Text(result.companyName)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(DSColors.textSecondary.opacity(0.8))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 3) {
                        // Price: primary
                        Text(priceText(result.price))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(DSColors.textPrimary)
                        
                        // % change: secondary, smaller
                        Text(percentText(result.percentChange))
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(changeColor(for: result.percentChange))
                    }
                }
            }
            .buttonStyle(.plain)
            .simultaneousGesture(
                TapGesture().onEnded {
                    viewModel.addToRecentSearches(result.ticker)
                }
            )
            
            // Action buttons with morphing animations
            HStack(spacing: 8) {
                // Forecast bookmark button
                Button(action: {
                    let wasAdded = !forecastStore.contains(ticker: result.ticker)
                    withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.6)) {
                        forecastStore.toggle(ticker: result.ticker)
                    }
                    triggerHaptic(style: .light)
                    if wasAdded {
                        showToast(message: "Added to Forecast", icon: "bookmark.fill")
                    } else {
                        showToast(message: "Removed from Forecast", icon: "bookmark.slash")
                    }
                }) {
                    Image(systemName: forecastStore.contains(ticker: result.ticker) ? "bookmark.fill" : "bookmark")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(forecastStore.contains(ticker: result.ticker) ? DSColors.accent : DSColors.textSecondary.opacity(0.7))
                        .frame(width: 40, height: 40)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(forecastStore.contains(ticker: result.ticker) ? "Remove from forecast" : "Add to forecast")
                
                // Watchlist button with plus → checkmark morph
                Button(action: {
                    let wasAdded = !watchlistStore.contains(ticker: result.ticker)
                    withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.65)) {
                        watchlistStore.toggle(ticker: result.ticker)
                    }
                    triggerHaptic(style: wasAdded ? .medium : .light)
                    if wasAdded {
                        showToast(message: "Added to Watchlist", icon: "checkmark.circle.fill")
                    } else {
                        showToast(message: "Removed from Watchlist", icon: "xmark.circle")
                    }
                }) {
                    ZStack {
                        // Morph between plus and checkmark
                        if watchlistStore.contains(ticker: result.ticker) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(DSColors.positive)
                                .transition(.scale.combined(with: .opacity))
                        } else {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 22, weight: .medium))
                                .foregroundColor(DSColors.accent)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(watchlistStore.contains(ticker: result.ticker) ? "Remove from watchlist" : "Add to watchlist")
            }
        }
        .padding(.horizontal, DSSpacing.l)
        .padding(.vertical, 14)
        .background(DSColors.surface)
        .contentShape(Rectangle())
    }
    
    private func changeColor(for percentChange: Double) -> Color {
        let magnitude = abs(percentChange)
        let baseColor = percentChange >= 0 ? DSColors.positive : DSColors.negative
        
        if magnitude > 5 {
            return baseColor
        } else if magnitude > 2 {
            return baseColor.opacity(0.85)
        } else {
            return baseColor.opacity(0.7)
        }
    }
    
    // MARK: - Recent Searches
    
    private var recentSearchesView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Searches")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(DSColors.textSecondary.opacity(0.7))
                .padding(.horizontal, DSSpacing.l)
                .padding(.top, 8)
            
            ForEach(viewModel.recentSearches, id: \.self) { query in
                Button {
                    viewModel.searchQuery = query
                    viewModel.addToRecentSearches(query)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14))
                            .foregroundColor(DSColors.textSecondary.opacity(0.6))
                        
                        Text(query)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(DSColors.textPrimary)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.left")
                            .font(.system(size: 12))
                            .foregroundColor(DSColors.textSecondary.opacity(0.5))
                    }
                    .padding(.horizontal, DSSpacing.l)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                
                if query != viewModel.recentSearches.last {
                    Divider()
                        .background(DSColors.border.opacity(0.5))
                        .padding(.leading, DSSpacing.l)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 44))
                .foregroundColor(DSColors.textSecondary.opacity(0.5))
            
            Text("No results found")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(DSColors.textPrimary)
            
            Text("Try searching for a different ticker or company name")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(DSColors.textSecondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.vertical, 70)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Helper Methods
    
    private func priceText(_ price: Double) -> String {
        return String(format: "$%.2f", price)
    }
    
    private func percentText(_ value: Double) -> String {
        let sign = value >= 0 ? "+" : ""
        return "\(sign)\(String(format: "%.2f", value))%"
    }
    
    private func triggerHaptic(style: UIImpactFeedbackGenerator.FeedbackStyle = .light) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func showToast(message: String, icon: String) {
        toastMessage = message
        toastIcon = icon
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showToast = true
        }
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5s
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showToast = false
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ZStack {
            DSColors.background.ignoresSafeArea()
            
            SearchOverlayView(viewModel: {
                let vm = BrowseViewModel()
                vm.searchQuery = "AAPL"
                vm.searchResults = [
                    TickerSearchResult(ticker: "AAPL", companyName: "Apple", price: 178.45, percentChange: 1.23),
                    TickerSearchResult(ticker: "MSFT", companyName: "Microsoft", price: 412.67, percentChange: -0.45)
                ]
                vm.showSearchOverlay = true
                return vm
            }())
            .environmentObject(WatchlistStore())
            .environmentObject(ForecastStore())
        }
    }
}
