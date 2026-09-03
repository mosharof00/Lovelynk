import SwiftUI
import WidgetKit

extension View {
    /// Apply on the **root** of each widget entry view.
    /// Required on iOS 17+ or the home/lock screen shows:
    /// "Please adopt containerBackground API".
    @ViewBuilder
    func lovelynkContainerBackground(
        style: WidgetStyleConfig,
        family: WidgetFamily
    ) -> some View {
        if #available(iOS 17.0, *) {
            switch family {
            case .accessoryCircular:
                self.containerBackground(for: .widget) {
                    AccessoryWidgetBackground()
                }
            case .accessoryRectangular, .accessoryInline:
                self.containerBackground(for: .widget) {
                    Color.clear
                }
            default:
                self.containerBackground(for: .widget) {
                    if style.useBackground {
                        style.backgroundColor
                    } else {
                        Color(UIColor.secondarySystemBackground)
                    }
                }
            }
        } else {
            switch family {
            case .accessoryCircular:
                ZStack {
                    AccessoryWidgetBackground()
                    self
                }
            case .accessoryRectangular, .accessoryInline:
                self
            default:
                if style.useBackground {
                    self.background(style.backgroundColor)
                } else {
                    self.background(Color(UIColor.secondarySystemBackground))
                }
            }
        }
    }
}
