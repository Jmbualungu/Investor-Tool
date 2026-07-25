import Foundation

enum Formatters {
    static func percent(_ value: Double) -> String {
        value.formatted(.percent.precision(.fractionLength(1)))
    }

    static func currency(_ value: Double) -> String {
        value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }

    static func number(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2)))
    }
    
    // MARK: - Enhanced Formatters with Nil Safety
    
    /// Formats a currency value with nil safety
    /// - Parameter value: Optional double value
    /// - Returns: Formatted currency string or "N/A" if nil
    static func formatCurrency(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        return value.formatted(.currency(code: Locale.current.currency?.identifier ?? "USD"))
    }
    
    /// Formats a number with specified decimal places and nil safety
    /// - Parameters:
    ///   - value: Optional double value
    ///   - decimals: Number of decimal places (default: 2)
    /// - Returns: Formatted number string or "N/A" if nil
    static func formatNumber(_ value: Double?, decimals: Int = 2) -> String {
        guard let value = value else { return "N/A" }
        return value.formatted(.number.precision(.fractionLength(decimals)))
    }
    
    /// Formats a percentage value with nil safety
    /// - Parameter value: Optional double value (e.g., 0.52 for 0.52%)
    /// - Returns: Formatted percentage string or "N/A" if nil
    static func formatPercent(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        return "\(value.formatted(.number.precision(.fractionLength(2))))%"
    }
    
    /// Formats market cap in billions or trillions
    /// - Parameter value: Optional double value representing market cap
    /// - Returns: Formatted string like "$2.8T" or "$693B" or "N/A" if nil
    static func formatMarketCap(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        
        if value >= 1_000_000_000_000 {
            let trillions = value / 1_000_000_000_000
            return "$\(trillions.formatted(.number.precision(.fractionLength(1))))T"
        } else if value >= 1_000_000_000 {
            let billions = value / 1_000_000_000
            return "$\(billions.formatted(.number.precision(.fractionLength(1))))B"
        } else if value >= 1_000_000 {
            let millions = value / 1_000_000
            return "$\(millions.formatted(.number.precision(.fractionLength(1))))M"
        } else {
            return formatCurrency(value)
        }
    }
    
    /// Formats volume in millions or billions
    /// - Parameter value: Optional double value representing volume
    /// - Returns: Formatted string like "84.2M" or "1.1B" or "N/A" if nil
    static func formatVolume(_ value: Double?) -> String {
        guard let value = value else { return "N/A" }
        
        if value >= 1_000_000_000 {
            let billions = value / 1_000_000_000
            return "\(billions.formatted(.number.precision(.fractionLength(1))))B"
        } else if value >= 1_000_000 {
            let millions = value / 1_000_000
            return "\(millions.formatted(.number.precision(.fractionLength(1))))M"
        } else if value >= 1_000 {
            let thousands = value / 1_000
            return "\(thousands.formatted(.number.precision(.fractionLength(1))))K"
        } else {
            return "\(Int(value))"
        }
    }
    
    /// Helper function for compact number formatting with custom suffix
    /// - Parameters:
    ///   - value: Optional double value
    ///   - suffix: Suffix to append (e.g., "M", "B", "K")
    /// - Returns: Formatted string with suffix or "N/A" if nil
    static func formatCompactNumber(_ value: Double?, suffix: String) -> String {
        guard let value = value else { return "N/A" }
        return "\(value.formatted(.number.precision(.fractionLength(1))))\(suffix)"
    }
    
    /// Formats a date with the specified style
    /// - Parameters:
    ///   - date: The date to format
    ///   - style: DateFormatter style (default: .medium)
    /// - Returns: Formatted date string
    static func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    /// Formats a date as relative time (e.g., "2h ago", "4h ago", "Jan 15")
    /// - Parameter date: The date to format
    /// - Returns: Formatted relative time string
    static func formatRelativeTime(_ date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)
        
        if interval < 3600 {
            // Less than 1 hour
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            // Less than 24 hours
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else if interval < 604800 {
            // Less than 7 days
            let days = Int(interval / 86400)
            return "\(days)d ago"
        } else {
            // More than 7 days, show date
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
    
    /// Formats a combined high/low value pair
    /// - Parameters:
    ///   - high: Optional high value
    ///   - low: Optional low value
    /// - Returns: Formatted string like "$223.10 / $216.40" or "N/A" if both nil
    static func formatHighLow(high: Double?, low: Double?) -> String {
        guard let high = high, let low = low else { return "N/A" }
        return "\(formatCurrency(high)) / \(formatCurrency(low))"
    }
    
    /// Formats an integer with thousands separators
    /// - Parameter value: Optional integer value
    /// - Returns: Formatted string like "164,000" or "N/A" if nil
    static func formatInteger(_ value: Int?) -> String {
        guard let value = value else { return "N/A" }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
