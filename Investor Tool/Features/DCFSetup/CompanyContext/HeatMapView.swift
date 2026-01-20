//
//  HeatMapView.swift
//  Investor Tool
//
//  Reusable heat map component for visualizing multi-dimensional data
//  Dark mode friendly, accessible, Robinhood-style design
//

import SwiftUI

struct HeatMapView: View {
    let model: HeatMapModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            // Column Headers
            HStack(spacing: 0) {
                // Left spacer for row labels
                Color.clear
                    .frame(width: 120)
                
                Spacer()
                
                // Column headers
                ForEach(model.columns, id: \.self) { column in
                    Text(column)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(DSColors.textSecondary)
                        .frame(width: cellWidth)
                }
            }
            .padding(.bottom, DSSpacing.xs)
            
            // Rows
            VStack(spacing: DSSpacing.m) {
                ForEach(model.rows) { row in
                    HeatMapRowView(row: row, cellWidth: cellWidth)
                }
            }
        }
    }
    
    // Cell width calculation
    private var cellWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - 32 - 120 - 16 // padding + label + spacing
        let columnCount = CGFloat(model.columns.count)
        return max(56, min(68, availableWidth / columnCount))
    }
}

// MARK: - Heat Map Row

private struct HeatMapRowView: View {
    let row: HeatMapRow
    let cellWidth: CGFloat
    
    var body: some View {
        HStack(spacing: DSSpacing.m) {
            // Row label
            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DSColors.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                
                Text(row.subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(DSColors.textTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(width: 120, alignment: .leading)
            
            Spacer()
            
            // Cells
            HStack(spacing: DSSpacing.s) {
                ForEach(row.values) { cell in
                    HeatMapCellView(cell: cell)
                        .frame(width: cellWidth)
                }
            }
        }
    }
}

// MARK: - Heat Map Cell

private struct HeatMapCellView: View {
    let cell: HeatMapCell
    
    var body: some View {
        Text(cell.label)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(cellTextColor)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(cellBackground)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(cellBorderColor, lineWidth: 0.5)
            )
            .accessibilityLabel("\(cell.label)")
    }
    
    // MARK: - Cell Styling
    
    private var cellBackground: some View {
        ZStack {
            // Base layer
            DSColors.surface
            
            // Intensity overlay
            Color.white
                .opacity(cellOpacity)
                .blendMode(.overlay)
        }
    }
    
    private var cellTextColor: Color {
        // Higher intensity = brighter text
        if cell.score > 0.7 {
            return DSColors.textPrimary
        } else if cell.score > 0.4 {
            return DSColors.textPrimary.opacity(0.9)
        } else {
            return DSColors.textSecondary
        }
    }
    
    private var cellBorderColor: Color {
        DSColors.border.opacity(0.3 + (cell.score * 0.4))
    }
    
    private var cellOpacity: Double {
        // Map score (0...1) to opacity range (0.12...0.45)
        // This creates subtle visual hierarchy without being garish
        let minOpacity = 0.12
        let maxOpacity = 0.45
        return minOpacity + (cell.score * (maxOpacity - minOpacity))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        DSColors.background
            .ignoresSafeArea()
        
        ScrollView {
            VStack(alignment: .leading, spacing: DSSpacing.l) {
                Text("At a glance")
                    .font(DSTypography.headline)
                    .foregroundColor(DSColors.textPrimary)
                
                HeatMapView(
                    model: HeatMapModel(
                        rows: [
                            HeatMapRow(
                                id: "growth",
                                title: "Revenue Growth",
                                subtitle: "Historical trajectory",
                                values: [
                                    HeatMapCell(id: "1y", score: 0.65, label: "Med"),
                                    HeatMapCell(id: "3y", score: 0.72, label: "Med-High"),
                                    HeatMapCell(id: "5y", score: 0.58, label: "Med")
                                ]
                            ),
                            HeatMapRow(
                                id: "margins",
                                title: "Profit Margins",
                                subtitle: "Operating efficiency",
                                values: [
                                    HeatMapCell(id: "1y", score: 0.88, label: "High"),
                                    HeatMapCell(id: "3y", score: 0.85, label: "High"),
                                    HeatMapCell(id: "5y", score: 0.82, label: "High")
                                ]
                            ),
                            HeatMapRow(
                                id: "volatility",
                                title: "Revenue Volatility",
                                subtitle: "Cyclical sensitivity",
                                values: [
                                    HeatMapCell(id: "1y", score: 0.35, label: "Low-Med"),
                                    HeatMapCell(id: "3y", score: 0.42, label: "Med"),
                                    HeatMapCell(id: "5y", score: 0.38, label: "Low-Med")
                                ]
                            ),
                            HeatMapRow(
                                id: "cashflow",
                                title: "FCF Conversion",
                                subtitle: "Cash generation power",
                                values: [
                                    HeatMapCell(id: "1y", score: 0.92, label: "High"),
                                    HeatMapCell(id: "3y", score: 0.90, label: "High"),
                                    HeatMapCell(id: "5y", score: 0.88, label: "High")
                                ]
                            )
                        ],
                        columns: ["1Y", "3Y", "5Y"]
                    )
                )
            }
            .padding(DSSpacing.l)
        }
    }
}
