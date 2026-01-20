//
//  PressableScaleModifier.swift
//  Investor Tool
//
//  Adds press feedback to interactive elements
//

import SwiftUI

struct PressableScaleModifier: ViewModifier {
    @GestureState private var isPressed = false
    let scale: CGFloat
    
    init(scale: CGFloat = 0.97) {
        self.scale = scale
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1.0)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
            .animation(Motion.emphasize, value: isPressed)
    }
}

extension View {
    /// Add press feedback with scale effect
    func pressableScale(_ scale: CGFloat = 0.97) -> some View {
        self.modifier(PressableScaleModifier(scale: scale))
    }
}

#Preview {
    VStack(spacing: 20) {
        Button("Press Me") {}
            .primaryCTAStyle()
            .pressableScale()
            .padding()
        
        Button {} label: {
            HStack {
                Image(systemName: "star.fill")
                Text("Favorite")
            }
            .padding()
            .background(DSColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .pressableScale()
    }
    .padding()
}
