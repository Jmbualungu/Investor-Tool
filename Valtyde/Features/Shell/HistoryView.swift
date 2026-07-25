import SwiftUI
import SwiftData

struct HistoryView: View {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    @EnvironmentObject private var store: AppItemStore
    @EnvironmentObject private var tabSelection: TabSelectionStore

    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            if store.items.isEmpty {
                EmptyStateView(
                    title: "No History",
                    message: "Generate a forecast to see your history here.",
                    actionTitle: "Go Home",
                    action: {
                        tabSelection.selectedTab = .home
                    }
                )
            } else {
                ScrollView {
                    VStack(spacing: DSSpacing.m) {
                        ForEach(store.items) { item in
                            NavigationLink {
                                ResultsView(item: item)
                            } label: {
                                DSGlassCard {
                                    HStack {
                                        VStack(alignment: .leading, spacing: DSSpacing.xs) {
                                            Text(item.title)
                                                .font(DSTypography.headline)
                                                .foregroundColor(DSColors.textPrimary)
                                            Text(Self.dateFormatter.string(from: item.createdAt))
                                                .font(DSTypography.caption)
                                                .foregroundColor(DSColors.textSecondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(DSColors.textSecondary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete { offsets in
                            store.deleteItem(at: offsets)
                        }
                    }
                    .padding(DSSpacing.l)
                }
            }
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    HistoryViewPreview()
}

private struct HistoryViewPreview: View {
    var body: some View {
        if let container = try? ModelContainer(
            for: AppItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ) {
            let store = AppItemStore()
            let tabs = TabSelectionStore()
            NavigationStack {
                HistoryView()
            }
            .environmentObject(store)
            .environmentObject(tabs)
            .modelContainer(container)
            .onAppear {
                store.configure(modelContext: container.mainContext)
            }
        } else {
            Text("Preview unavailable")
                .padding()
        }
    }
}
