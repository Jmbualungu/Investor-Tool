//
//  ToastNotification.swift
//  Investor Tool
//
//  Lightweight toast notification for temporary feedback
//

import SwiftUI

struct ToastNotification: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(DSTypography.subheadline)
            .fontWeight(.medium)
            .foregroundColor(DSColors.textPrimary)
            .padding(.horizontal, DSSpacing.l)
            .padding(.vertical, DSSpacing.m)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(DSColors.border, lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct ToastModifier: ViewModifier {
    @Binding var isPresented: Bool
    let message: String
    let duration: TimeInterval
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isPresented {
                VStack {
                    Spacer()
                    ToastNotification(message: message)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, DSSpacing.xl)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                        Motion.withAnimation(Motion.disappear) {
                            isPresented = false
                        }
                    }
                }
            }
        }
        .animation(Motion.appear, value: isPresented)
    }
}

extension View {
    func toast(
        isPresented: Binding<Bool>,
        message: String,
        duration: TimeInterval = 1.2
    ) -> some View {
        self.modifier(ToastModifier(
            isPresented: isPresented,
            message: message,
            duration: duration
        ))
    }
}

#Preview {
    @Previewable @State var showToast = true
    
    VStack {
        Text("Content")
        
        Button("Show Toast") {
            showToast = true
        }
    }
    .toast(isPresented: $showToast, message: "Scenario applied")
}
