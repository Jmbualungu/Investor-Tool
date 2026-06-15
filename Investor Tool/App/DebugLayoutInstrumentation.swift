//
//  DebugLayoutInstrumentation.swift
//  Investor Tool
//
//  DEBUG-only overlay and console logging to identify letterboxing/clipping.
//  Remove this file or wrap all usage in #if DEBUG when done diagnosing.
//

#if DEBUG
import Combine
import SwiftUI
import UIKit

// MARK: - Layout snapshot (UIKit + SwiftUI)

struct DebugLayoutSnapshot {
    var screenBounds: CGRect = .zero
    var windowBounds: CGRect?
    var rootVCViewBounds: CGRect?
    var windowSafeArea: UIEdgeInsets = .zero
    var swiftUISize: CGSize = .zero
    var swiftUISafeArea: EdgeInsets = EdgeInsets()
    
    static let empty = DebugLayoutSnapshot()
}

// MARK: - Fetch UIKit layout

func DebugLayoutFetchUIKit() -> (screen: CGRect, window: CGRect?, rootVC: CGRect?, windowSafeArea: UIEdgeInsets) {
    let screen = UIScreen.main.bounds
    var windowBounds: CGRect?
    var rootVCBounds: CGRect?
    var windowSafeArea: UIEdgeInsets = .zero
    
    guard let scene = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .first(where: { $0.activationState == .foregroundActive })
        ?? UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }).first else {
        return (screen, nil, nil, .zero)
    }
    
    let win = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
    if let w = win {
        windowBounds = w.bounds
        windowSafeArea = w.safeAreaInsets
        if let rvc = w.rootViewController {
            rootVCBounds = rvc.view.bounds
        }
    }
    
    return (screen, windowBounds, rootVCBounds, windowSafeArea)
}

// MARK: - Console logging

func DebugLayoutLog(_ context: String, snapshot: DebugLayoutSnapshot) {
    print("─────────────── 📐 [Layout] \(context) ───────────────")
    print("  UIScreen.main.bounds:     \(snapshot.screenBounds)")
    print("  window.bounds:            \(String(describing: snapshot.windowBounds))")
    print("  rootVC.view.bounds:       \(String(describing: snapshot.rootVCViewBounds))")
    print("  window.safeAreaInsets:    top=\(snapshot.windowSafeArea.top) L=\(snapshot.windowSafeArea.left) B=\(snapshot.windowSafeArea.bottom) R=\(snapshot.windowSafeArea.right)")
    print("  SwiftUI GeometryReader:   \(snapshot.swiftUISize.width)×\(snapshot.swiftUISize.height)")
    print("  SwiftUI safeAreaInsets:   top=\(snapshot.swiftUISafeArea.top) L=\(snapshot.swiftUISafeArea.leading) B=\(snapshot.swiftUISafeArea.bottom) R=\(snapshot.swiftUISafeArea.trailing)")
    
    let screenH = snapshot.screenBounds.height
    let winH = snapshot.windowBounds?.height ?? 0
    let rvcH = snapshot.rootVCViewBounds?.height ?? 0
    let swH = snapshot.swiftUISize.height
    
    if winH > 0 && winH < screenH - 1 {
        print("  ⚠️ window.bounds SMALLER than screen => window/scene setup")
    }
    if rvcH > 0 && winH > 0 && rvcH < winH - 1 {
        print("  ⚠️ rootVC.view.bounds SMALLER than window => UIKit constraint")
    }
    if swH > 0 && rvcH > 0 && swH < rvcH - 1 {
        print("  ⚠️ SwiftUI size SMALLER than rootVC => SwiftUI layout constraint")
    }
    if swH > 0 && winH > 0 && swH < winH - 1 && abs(rvcH - winH) < 1 {
        print("  ⚠️ SwiftUI size SMALLER than window (rootVC=window) => SwiftUI layout")
    }
    print("─────────────────────────────────────────────────────")
}

/// Call from onboarding/paywall to log current layout. Uses shared store + fresh UIKit fetch.
func DebugLayoutLogFromContext(_ context: String) {
    let store = DebugLayoutStore.shared
    let (screen, win, rvc, insets) = DebugLayoutFetchUIKit()
    var s = store.snapshot
    s.screenBounds = screen
    s.windowBounds = win
    s.rootVCViewBounds = rvc
    s.windowSafeArea = insets
    DebugLayoutLog(context, snapshot: s)
}

// MARK: - Overlay view (small top-left, shows snapshot)

private struct DebugLayoutOverlayView: View {
    @ObservedObject var store: DebugLayoutStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("📐 Layout")
                .font(.caption2.bold())
            Text("screen: \(fmtRect(store.snapshot.screenBounds))")
                .font(.system(size: 9, design: .monospaced))
            Text("window: \(fmt(store.snapshot.windowBounds))")
                .font(.system(size: 9, design: .monospaced))
            Text("rootVC: \(fmt(store.snapshot.rootVCViewBounds))")
                .font(.system(size: 9, design: .monospaced))
            Text("SwiftUI: \(Int(store.snapshot.swiftUISize.width))×\(Int(store.snapshot.swiftUISize.height))")
                .font(.system(size: 9, design: .monospaced))
            Text("win insets: T\(Int(store.snapshot.windowSafeArea.top)) B\(Int(store.snapshot.windowSafeArea.bottom))")
                .font(.system(size: 9, design: .monospaced))
            Text("SW insets: T\(Int(store.snapshot.swiftUISafeArea.top)) B\(Int(store.snapshot.swiftUISafeArea.bottom))")
                .font(.system(size: 9, design: .monospaced))
        }
        .padding(8)
        .frame(maxWidth: 200, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.top, 8)
        .padding(.leading, 8)
        .onAppear {
            refreshUIKit()
            DebugLayoutLog("App launch (root overlay)", snapshot: store.snapshot)
        }
        .task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            refreshUIKit()
            DebugLayoutLog("App launch (after 0.3s settle)", snapshot: store.snapshot)
        }
    }
    
    private func refreshUIKit() {
        let (screen, win, rvc, insets) = DebugLayoutFetchUIKit()
        store.updateUIKit(screen: screen, window: win, rootVC: rvc, windowSafeArea: insets)
    }
}

private func fmt(_ r: CGRect?) -> String {
    guard let r = r else { return "—" }
    return "\(Int(r.width))×\(Int(r.height))"
}
private func fmtRect(_ r: CGRect) -> String {
    "\(Int(r.width))×\(Int(r.height))"
}

// MARK: - Store (SwiftUI size from background GeoReader + UIKit from overlay)

final class DebugLayoutStore: ObservableObject {
    static let shared = DebugLayoutStore()
    
    @Published private(set) var snapshot = DebugLayoutSnapshot.empty
    
    func updateSwiftUI(size: CGSize, safeArea: EdgeInsets) {
        var next = snapshot
        next.swiftUISize = size
        next.swiftUISafeArea = safeArea
        snapshot = next
    }
    
    func updateUIKit(screen: CGRect, window: CGRect?, rootVC: CGRect?, windowSafeArea: UIEdgeInsets) {
        var next = snapshot
        next.screenBounds = screen
        next.windowBounds = window
        next.rootVCViewBounds = rootVC
        next.windowSafeArea = windowSafeArea
        snapshot = next
    }
}

// MARK: - View modifier (background GeometryReader + overlay)

struct DebugLayoutInstrumentationModifier: ViewModifier {
    private let store = DebugLayoutStore.shared
    
    func body(content: Content) -> some View {
        content
            .background {
                GeometryReader { g in
                    Color.clear
                        .onAppear { store.updateSwiftUI(size: g.size, safeArea: g.safeAreaInsets) }
                }
                .allowsHitTesting(false)
            }
            .overlay(alignment: .topLeading) {
                DebugLayoutOverlayView(store: store)
                    .allowsHitTesting(false)
            }
    }
}

extension View {
    /// DEBUG-only: overlay + console logging for layout diagnosis. Remove when done.
    func debugLayoutInstrumentation() -> some View {
        modifier(DebugLayoutInstrumentationModifier())
    }
}
#endif
