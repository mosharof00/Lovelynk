import SwiftUI
import WidgetKit

extension View {
    @ViewBuilder
    func widgetBackground(_ style: WidgetStyleConfig) -> some View {
        if style.useBackground {
            if #available(iOS 17.0, *) {
                self.containerBackground(style.backgroundColor, for: .widget)
            } else {
                self.background(style.backgroundColor)
            }
        } else {
            if #available(iOS 17.0, *) {
                self.containerBackground(.fill.tertiary, for: .widget)
            } else {
                self.background()
            }
        }
    }

    /// iOS 17+ requires `containerBackground(for: .widget)` on lock-screen accessory widgets.
    /// Without this, real devices show: "Please adopt containerBackground API".
    @ViewBuilder
    func accessoryWidgetContainer(family: WidgetFamily) -> some View {
        if #available(iOS 17.0, *) {
            switch family {
            case .accessoryCircular:
                self.containerBackground(for: .widget) {
                    AccessoryWidgetBackground()
                }
            case .accessoryRectangular, .accessoryInline:
                self.containerBackground(.fill.tertiary, for: .widget)
            default:
                self
            }
        } else {
            switch family {
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    self
                }
            default:
                self
            }
        }
    }
}
