import Foundation

/// App Group + storage keys — must match Dart `WidgetAppGroup`.
enum WidgetKeys {
    static let appGroupId = "group.com.lovelynk.app"

    static let globalLocked = "widget_global_locked"
    static let globalLockMessage = "widget_global_lock_message"

    enum DaysTogether {
        static let widgetId = "days_together"
        static let count = "days_together_count"
        static let title = "days_together_title"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }

    enum Initials {
        static let widgetId = "initials"
        static let userInitial = "initials_user_initial"
        static let partnerInitial = "initials_partner_initial"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }
}
