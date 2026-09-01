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

    enum PartnerTime {
        static let widgetId = "partner_time"
        static let utcOffsetHours = "partner_time_utc_offset_hours"
        static let city = "partner_time_city"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }

    enum TogetherCounter {
        static let widgetId = "together_counter"
        static let since = "together_counter_since"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }

    enum NextVisit {
        static let widgetId = "next_visit_countdown"
        static let targetAt = "next_visit_target_at"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }

    enum PartnerWeather {
        static let widgetId = "partner_weather"
        static let temperature = "partner_weather_temperature"
        static let condition = "partner_weather_condition"
        static let city = "partner_weather_city"
        static let iconKey = "partner_weather_icon_key"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }

    enum LoveCompass {
        static let widgetId = "love_compass"
        static let miles = "love_compass_miles"
        static let partnerLabel = "love_compass_partner_label"
        static let needleDegrees = "love_compass_needle_degrees"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }

    enum Heartbeat {
        static let widgetId = "heartbeat"
        static let count = "heartbeat_count"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }

    enum Kiss {
        static let widgetId = "kiss"
        static let count = "kiss_count"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }

    enum Emoji {
        static let widgetId = "emoji"
        static let recent = "emoji_recent"

        static func style(_ field: String) -> String { "\(widgetId)_\(field)" }
    }
}
