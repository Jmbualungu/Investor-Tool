import SwiftUI
import SwiftData

struct PrimaryActionView: View {
    @EnvironmentObject private var store: AppItemStore
    @State private var inputText: String = ""
    @State private var mode: OutputMode = .summarize
    @State private var generatedItem: AppItem?

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text("Primary Action")
                .font(DesignTokens.Fonts.title)
            Text("Empty state: No inputs captured yet.")
                .font(DesignTokens.Fonts.body)
                .foregroundColor(DesignTokens.Colors.textSecondary)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text("Input")
                    .font(DesignTokens.Fonts.headline)
                ZStack(alignment: .topLeading) {
                    if inputText.isEmpty {
                        Text("Enter text to transform…")
                            .font(DesignTokens.Fonts.body)
                            .foregroundColor(DesignTokens.Colors.textSecondary)
                            .padding(.vertical, DesignTokens.Spacing.sm)
                            .padding(.horizontal, DesignTokens.Spacing.sm)
                    }
                    TextEditor(text: $inputText)
                        .padding(DesignTokens.Spacing.xs)
                        .frame(minHeight: 140)
                        .background(DesignTokens.Colors.card)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.md, style: .continuous))
                }
            }

            Picker("Mode", selection: $mode) {
                ForEach(OutputMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Button("Generate") {
                let output = transform(input: inputText, mode: mode)
                let title = deriveTitle(from: inputText)
                let item = store.addItem(title: title, input: inputText, output: output)
                print("Generated item:", item.title)
                generatedItem = item
            }
            .buttonStyle(.borderedProminent)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(DesignTokens.Spacing.xl)
        .navigationTitle("Primary Action")
        .navigationDestination(item: $generatedItem) { item in
            ResultsView(item: item)
        }
    }
}

#Preview {
    PrimaryActionViewPreview()
}

private struct PrimaryActionViewPreview: View {
    var body: some View {
        if let container = try? ModelContainer(
            for: AppItem.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        ) {
            let store = AppItemStore()
            let tabs = TabSelectionStore()
            NavigationStack {
                PrimaryActionView()
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

private enum OutputMode: String, CaseIterable, Identifiable {
    case summarize
    case bullets
    case rephrase

    var id: String { rawValue }

    var title: String {
        switch self {
        case .summarize:
            return "Summarize"
        case .bullets:
            return "Bullets"
        case .rephrase:
            return "Rephrase"
        }
    }
}

private func transform(input: String, mode: OutputMode) -> String {
    let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return "No input provided." }

    switch mode {
    case .summarize:
        let sentences = splitSentences(from: trimmed)
        if sentences.count >= 2 {
            return sentences.prefix(2).joined(separator: " ") + "..."
        }
        let prefix = String(trimmed.prefix(280))
        return prefix + (prefix.count < trimmed.count ? "..." : "")
    case .bullets:
        let sentences = splitSentences(from: trimmed)
        let items = sentences.isEmpty ? [trimmed] : sentences
        return items.map { "• \($0)" }.joined(separator: "\n")
    case .rephrase:
        return rephrase(trimmed)
    }
}

private func splitSentences(from text: String) -> [String] {
    text
        .replacingOccurrences(of: "\n", with: " ")
        .split(whereSeparator: { ".!?".contains($0) })
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
}

private func rephrase(_ text: String) -> String {
    let lower = text.lowercased()
    let replacements: [(String, String)] = [
        ("very", "highly"),
        ("important", "key"),
        ("good", "strong"),
        ("bad", "weak"),
        ("use", "apply"),
        ("show", "demonstrate")
    ]
    let replaced = replacements.reduce(lower) { result, pair in
        result.replacingOccurrences(of: pair.0, with: pair.1)
    }
    return sentenceCase(replaced.trimmingCharacters(in: .whitespacesAndNewlines))
}

private func sentenceCase(_ text: String) -> String {
    guard let first = text.first else { return text }
    return first.uppercased() + text.dropFirst()
}

private func deriveTitle(from text: String) -> String {
    let words = text.split(whereSeparator: { $0.isWhitespace || $0.isNewline })
    let prefix = words.prefix(4).joined(separator: " ")
    return prefix.isEmpty ? "Untitled" : String(prefix)
}
