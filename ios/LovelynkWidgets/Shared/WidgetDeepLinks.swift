import Foundation

/// Reserved deep-link URLs for home and lock screen widgets.
/// Opens directly into the corresponding screen in the Flutter app.
enum WidgetDeepLinks {
    static let baseScheme = "lovelynk"
    static let baseHost = "widget"

    static func url(for widgetId: String) -> URL? {
        URL(string: "\(baseScheme)://\(baseHost)/\(widgetId)?homeWidget")
    }
}
