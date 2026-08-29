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
}
