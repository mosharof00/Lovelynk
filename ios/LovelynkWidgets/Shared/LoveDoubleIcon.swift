import SwiftUI

/// Overlapping double-heart mark matching app asset `love_double_icon.svg`.
struct LoveDoubleIcon: View {
    var size: CGFloat
    var color: Color

    var body: some View {
        ZStack {
            // Larger heart (back-left), matching SVG lower heart
            Image(systemName: "heart.fill")
                .font(.system(size: size * 0.78))
                .offset(x: -size * 0.14, y: size * 0.06)

            // Smaller heart (front-right), matching SVG upper heart
            Image(systemName: "heart.fill")
                .font(.system(size: size * 0.58))
                .offset(x: size * 0.18, y: -size * 0.1)
        }
        .foregroundStyle(color)
        .frame(width: size, height: size)
        .accessibilityLabel("Love")
    }
}
