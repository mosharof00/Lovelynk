import SwiftUI

/// Compass dial with N/E/S/W labels and a rotating needle.
struct CompassDialView: View {
    let needleDegrees: Double
    let size: CGFloat
    let color: Color

    private let cardinals = ["N", "E", "S", "W"]

    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: 1.5)
                .frame(width: size * 0.78, height: size * 0.78)

            ForEach(Array(cardinals.enumerated()), id: \.offset) { index, label in
                Text(label)
                    .font(.system(size: max(7, size * 0.12), weight: .semibold))
                    .foregroundStyle(color)
                    .offset(cardinalOffset(for: index, radius: size * 0.42))
            }

            Image(systemName: "location.north.fill")
                .font(.system(size: size * 0.34, weight: .bold))
                .foregroundStyle(color)
                .rotationEffect(.degrees(needleDegrees))
        }
        .frame(width: size, height: size)
    }

    private func cardinalOffset(for index: Int, radius: CGFloat) -> CGSize {
        let angle = Double(index) * 90 - 90
        let radians = angle * .pi / 180
        return CGSize(
            width: CGFloat(cos(radians)) * radius,
            height: CGFloat(sin(radians)) * radius
        )
    }
}
