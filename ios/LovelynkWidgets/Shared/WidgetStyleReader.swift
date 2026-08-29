import SwiftUI

/// Parsed customise style for a widget (from App Group).
struct WidgetStyleConfig {
    let themeColor: Color
    let useBackground: Bool
    let backgroundColor: Color
    let font: Font
    let titleSize: CGFloat
    let valueSize: CGFloat

    static func load(widgetId: String) -> WidgetStyleConfig {
        let themeId = AppGroupStore.string("\(widgetId)_themeColorId", default: "rose")
        let bgId = AppGroupStore.string("\(widgetId)_backgroundColorId", default: "rose")
        let useBg = AppGroupStore.bool("\(widgetId)_useBackground")
        let fontName = AppGroupStore.string("\(widgetId)_font", default: "sfPro")
        let textSize = AppGroupStore.string("\(widgetId)_textSize", default: "medium")

        let (titleSize, valueSize) = Self.sizes(for: textSize)
        return WidgetStyleConfig(
            themeColor: Self.color(for: themeId),
            useBackground: useBg,
            backgroundColor: Self.color(for: bgId),
            font: Self.font(for: fontName, valueSize: valueSize),
            titleSize: titleSize,
            valueSize: valueSize
        )
    }

    private static func sizes(for textSize: String) -> (CGFloat, CGFloat) {
        switch textSize {
        case "small": return (10, 28)
        case "large": return (14, 40)
        default: return (12, 34)
        }
    }

    private static func font(for name: String, valueSize: CGFloat) -> Font {
        switch name {
        case "sfProRounded":
            return .system(size: valueSize, weight: .bold, design: .rounded)
        case "newYork":
            return .system(size: valueSize, weight: .bold, design: .serif)
        default:
            return .system(size: valueSize, weight: .bold, design: .default)
        }
    }

    private static func color(for id: String) -> Color {
        if id.hasPrefix("custom_") {
            let hex = String(id.dropFirst("custom_".count))
            if hex.count == 8, let value = UInt32(hex, radix: 16) {
                let a = Double((value >> 24) & 0xFF) / 255
                let r = Double((value >> 16) & 0xFF) / 255
                let g = Double((value >> 8) & 0xFF) / 255
                let b = Double(value & 0xFF) / 255
                return Color(red: r, green: g, blue: b, opacity: a)
            }
        }
        switch id {
        case "sky": return Color(red: 0.26, green: 0.76, blue: 1.0)
        case "lavender": return Color(red: 0.61, green: 0.49, blue: 0.87)
        case "peach": return Color(red: 1.0, green: 0.56, blue: 0.42)
        case "mint": return Color(red: 0.31, green: 0.80, blue: 0.77)
        case "ink": return Color(red: 0.10, green: 0.08, blue: 0.19)
        default: return Color(red: 1.0, green: 0.31, blue: 0.64) // rose
        }
    }
}
