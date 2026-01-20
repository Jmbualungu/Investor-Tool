//
//  Sparkline.swift
//  Investor Tool
//
//  Minimal sparkline chart component using pure SwiftUI
//

import SwiftUI

struct Sparkline: View {
    let points: [Double]
    let height: CGFloat
    let lineColor: Color
    
    init(points: [Double], height: CGFloat = 32, lineColor: Color = DSColors.accent) {
        self.points = points
        self.height = height
        self.lineColor = lineColor
    }
    
    var body: some View {
        GeometryReader { geometry in
            if points.count > 1 {
                Path { path in
                    let minValue = points.min() ?? 0
                    let maxValue = points.max() ?? 1
                    let range = maxValue - minValue
                    
                    // Avoid division by zero
                    guard range > 0 else {
                        // Draw a flat line in the middle
                        path.move(to: CGPoint(x: 0, y: geometry.size.height / 2))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height / 2))
                        return
                    }
                    
                    let xStep = geometry.size.width / CGFloat(points.count - 1)
                    
                    for (index, point) in points.enumerated() {
                        let x = CGFloat(index) * xStep
                        // Normalize point to 0...1, then invert for y-coordinate
                        let normalized = (point - minValue) / range
                        let y = geometry.size.height * (1.0 - normalized)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [
                            lineColor.opacity(0.8),
                            lineColor.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
            } else {
                // Not enough points
                EmptyView()
            }
        }
        .frame(height: height)
    }
}

#Preview {
    VStack(spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
            Text("Revenue Trend")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Sparkline(points: [100, 110, 125, 135, 150, 160], height: 28)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Intrinsic Value Trend")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Sparkline(points: [150, 165, 190, 220, 255, 280], height: 36)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Flat Line (Edge Case)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Sparkline(points: [100, 100, 100, 100, 100, 100], height: 28)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
    }
    .padding()
    .background(Color(.systemGray6))
}
