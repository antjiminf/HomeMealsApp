import Foundation

extension NumberFormatter {
    static var decimalFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 1
        return formatter
    }
}

extension Int {
    var formattedLikes: String {
        if self >= 1_000_000 {
            return String(format: "%.1fM", Double(self) / 1_000_000).replacingOccurrences(of: ".0", with: "")
        } else if self >= 1_000 {
            return String(format: "%.1fk", Double(self) / 1_000).replacingOccurrences(of: ".0", with: "")
        } else {
            return "\(self)"
        }
    }
}

extension Date {
    var dateFormatter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: self)
    }
}

extension Date {
    var normalized: Date {
        Calendar.current.startOfDay(for: self)
    }
}
