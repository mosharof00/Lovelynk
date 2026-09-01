import Foundation

/// Deep links opened when the user taps an interactive widget.
/// `homeWidget` query param is required for `home_widget` plugin URL handling.
enum WidgetDeepLinks {
    static let heartbeat = URL(string: "lovelynk://widget/heartbeat?homeWidget")!
    static let kiss = URL(string: "lovelynk://widget/kiss?homeWidget")!
    static let emoji = URL(string: "lovelynk://widget/emoji?homeWidget")!
}
