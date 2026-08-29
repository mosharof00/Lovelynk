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
}
