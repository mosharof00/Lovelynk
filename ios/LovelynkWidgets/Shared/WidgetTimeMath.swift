import Foundation

/// Shared time helpers for live timeline widgets.
enum WidgetTimeMath {
    /// Mirrors Dart `now.toUtc().add(Duration(hours: offsetHours))` hour/minute.
    static func partnerClock(at date: Date, offsetHours: Int) -> (hour: Int, minute: Int) {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        let utcHour = parts.hour ?? 0
        let utcMinute = parts.minute ?? 0
        var totalMinutes = utcHour * 60 + utcMinute + offsetHours * 60
        let dayMinutes = 24 * 60
        totalMinutes = ((totalMinutes % dayMinutes) + dayMinutes) % dayMinutes
        return (totalMinutes / 60, totalMinutes % 60)
    }

    static func format12Hour(hour: Int, minute: Int) -> (time: String, period: String) {
        let period = hour >= 12 ? "PM" : "AM"
        let hour12 = hour % 12 == 0 ? 12 : hour % 12
        return (String(format: "%d:%02d", hour12, minute), period)
    }

    static func durationComponents(from start: Date, to end: Date) -> (days: Int, hours: Int, minutes: Int, seconds: Int) {
        let interval = max(0, Int(end.timeIntervalSince(start)))
        let days = interval / 86_400
        let hours = (interval % 86_400) / 3_600
        let minutes = (interval % 3_600) / 60
        let seconds = interval % 60
        return (days, hours, minutes, seconds)
    }
}
