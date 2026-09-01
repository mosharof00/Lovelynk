import Foundation

/// Reads shared values written by Flutter via `home_widget` / App Group.
enum AppGroupStore {
    private static var defaults: UserDefaults? {
        UserDefaults(suiteName: WidgetKeys.appGroupId)
    }

    static func string(_ key: String, default defaultValue: String = "") -> String {
        defaults?.string(forKey: key) ?? defaultValue
    }

    static func bool(_ key: String) -> Bool {
        defaults?.string(forKey: key) == "1"
    }

    static func int(_ key: String, default defaultValue: Int = 0) -> Int {
        let raw = defaults?.string(forKey: key) ?? ""
        return Int(raw) ?? defaultValue
    }

    static func isoDate(_ key: String) -> Date? {
        let raw = defaults?.string(forKey: key) ?? ""
        guard !raw.isEmpty else { return nil }

        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = fractional.date(from: raw) { return date }

        let standard = ISO8601DateFormatter()
        standard.formatOptions = [.withInternetDateTime]
        return standard.date(from: raw)
    }

    static func double(_ key: String, default defaultValue: Double = 0) -> Double {
        let raw = defaults?.string(forKey: key) ?? ""
        return Double(raw) ?? defaultValue
    }
}
