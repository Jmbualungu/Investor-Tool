import SwiftUI

struct AboutSectionView: View {
    let profile: CompanyProfile
    
    var body: some View {
        VStack(alignment: .leading, spacing: DSSpacing.m) {
            DSSectionHeader(title: "About")
            
            DSCard {
                VStack(alignment: .leading, spacing: DSSpacing.m) {
                    Text(profile.description)
                        .dsBody()
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                    
                    Divider()
                        .background(DSColors.border)
                    
                    HStack(spacing: DSSpacing.l) {
                        keyFactItem(label: "CEO", value: profile.ceo)
                        keyFactItem(label: "Employees", value: Formatters.formatInteger(profile.employees))
                    }
                    
                    HStack(spacing: DSSpacing.l) {
                        keyFactItem(label: "Founded", value: profile.foundedYear > 0 ? "\(profile.foundedYear)" : "N/A")
                        keyFactItem(label: "HQ", value: profile.headquarters)
                    }
                }
            }
        }
    }
    
    private func keyFactItem(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(DSTypography.caption)
                .foregroundColor(DSColors.textSecondary)
            Text(value)
                .font(DSTypography.subheadline)
                .foregroundColor(DSColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AboutSectionView_Previews: PreviewProvider {
    static var previews: some View {
        let profile = CompanyProfile(
            description: "Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company is known for its innovative products including iPhone, iPad, Mac, Apple Watch, and services.",
            ceo: "Tim Cook",
            employees: 164_000,
            foundedYear: 1976,
            headquarters: "Cupertino, California"
        )
        
        return VStack {
            AboutSectionView(profile: profile)
                .padding()
        }
        .background(DSColors.background)
    }
}
