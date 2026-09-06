import SwiftUI

/// System-driven timer text — iOS updates every second without WidgetKit timeline spam.
enum WidgetLiveTimer {
    /// Elapsed time from a past date (Together Counter).
    @ViewBuilder
    static func countUp(
        from since: Date,
        font: Font,
        color: Color? = nil
    ) -> some View {
        Text(since, style: .timer)
            .font(font)
            .monospacedDigit()
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .modifier(OptionalForeground(color: color))
    }

    /// Remaining time until a future date (Next Visit). Shows zeros if past/missing.
    @ViewBuilder
    static func countDown(
        to target: Date?,
        font: Font,
        color: Color? = nil
    ) -> some View {
        Group {
            if let target, target > Date() {
                Text(target, style: .timer)
            } else {
                Text("0:00")
            }
        }
        .font(font)
        .monospacedDigit()
        .minimumScaleFactor(0.5)
        .lineLimit(1)
        .modifier(OptionalForeground(color: color))
    }
}

private struct OptionalForeground: ViewModifier {
    let color: Color?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let color {
            content.foregroundStyle(color)
        } else {
            content
        }
    }
}
