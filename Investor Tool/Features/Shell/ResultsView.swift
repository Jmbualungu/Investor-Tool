import SwiftUI

struct ResultsView: View {
    let item: AppItem

    var body: some View {
        ZStack {
            DSColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: DSSpacing.l) {
                    // Title
                    Text(item.title)
                        .dsTitle()
                    
                    // Input Section
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.s) {
                            Text("Input")
                                .dsHeadline()
                            Text(item.input)
                                .dsBody()
                        }
                    }

                    // Output Section
                    DSGlassCard {
                        VStack(alignment: .leading, spacing: DSSpacing.s) {
                            Text("Output")
                                .dsHeadline()
                            
                            if item.output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("No output generated")
                                    .dsCaption()
                            } else {
                                Text(item.output)
                                    .dsBody()
                            }
                        }
                    }
                }
                .padding(DSSpacing.l)
            }
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        ResultsView(item: MockData.appItems.first!)
    }
}
