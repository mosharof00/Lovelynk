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

    enum PartnerDistance {
        static let widgetId = "partner_distance"
        static let miles = "partner_distance_miles"
        static let userInitial = "partner_distance_user_initial"
        static let partnerInitial = "partner_distance_partner_initial"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }

    enum Anniversary {
        static let widgetId = "anniversary"
        static let dateLabel = "anniversary_date_label"
        static let daysToGo = "anniversary_days_to_go"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }
}
