import Foundation

extension Date {
    func formattedFull(style: DateFormatter.Style = .full, locale: Locale = Locale(identifier: "en_EN")) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
}
