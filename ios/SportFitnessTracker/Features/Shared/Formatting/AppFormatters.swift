import Foundation

enum AppFormatters {
    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let compactDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let number: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter
    }()

    static func string(for number: Double) -> String {
        number.string(with: number)
    }
}

private extension Double {
    func string(with formatter: NumberFormatter) -> String {
        formatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}