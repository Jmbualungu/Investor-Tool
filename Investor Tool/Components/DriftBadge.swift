//
//  DriftBadge.swift
//  Investor Tool
//
//  Premium feature: Shows when user has edited assumptions away from base
//

import SwiftUI

struct DriftBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "pencil")
                .font(.system(size: 10, weight: .semibold))
            
            Text("Edited")
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundColor(DSColors.accent)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(DSColors.accent.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .stroke(DSColors.accent.opacity(0.3), lineWidth: 1)
        )
    }
}

struct DriftDot: View {
    var body: some View {
        Circle()
            .fill(DSColors.accent)
            .frame(width: 6, height: 6)
    }
}

#Preview {
    VStack(spacing: 20) {
        DriftBadge()
        
        HStack {
            Text("Revenue Growth")
            DriftDot()
        }
    }
    .padding()
}
