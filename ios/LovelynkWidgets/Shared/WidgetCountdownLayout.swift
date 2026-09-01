import SwiftUI
import WidgetKit

/// Shared D : H : M : S layouts for live counter widgets.
enum WidgetCountdownLayout {
  static func smallGrid(
    days: Int,
    hours: Int,
    minutes: Int,
    seconds: Int,
    style: WidgetStyleConfig,
    family: WidgetFamily
  ) -> some View {
    let valueSize = style.homeValueSize(for: family) * 0.36
    let labelSize: CGFloat = 8

    return VStack(spacing: 5) {
      HStack(spacing: 0) {
        counterUnit(days, label: "D", valueSize: valueSize, labelSize: labelSize, style: style)
        colon(size: valueSize * 0.85, style: style)
        counterUnit(hours, label: "H", valueSize: valueSize, labelSize: labelSize, style: style)
      }
      HStack(spacing: 0) {
        counterUnit(minutes, label: "M", valueSize: valueSize, labelSize: labelSize, style: style)
        colon(size: valueSize * 0.85, style: style)
        counterUnit(seconds, label: "S", valueSize: valueSize, labelSize: labelSize, style: style)
      }
    }
    .frame(maxWidth: .infinity)
  }

  static func mediumRow(
    days: Int,
    hours: Int,
    minutes: Int,
    seconds: Int,
    style: WidgetStyleConfig,
    family: WidgetFamily
  ) -> some View {
    let valueSize = style.homeValueSize(for: family) * 0.48
    let labelSize = style.homeTitleSize(for: family) - 2

    return HStack(alignment: .top, spacing: 4) {
      counterUnit(days, label: "DAY", valueSize: valueSize, labelSize: labelSize, style: style)
      colon(size: valueSize, style: style)
      counterUnit(hours, label: "HOUR", valueSize: valueSize, labelSize: labelSize, style: style)
      colon(size: valueSize, style: style)
      counterUnit(minutes, label: "MIN", valueSize: valueSize, labelSize: labelSize, style: style)
      colon(size: valueSize, style: style)
      counterUnit(seconds, label: "SEC", valueSize: valueSize, labelSize: labelSize, style: style)
    }
    .frame(maxWidth: .infinity)
  }

  private static func counterUnit(
    _ value: Int,
    label: String,
    valueSize: CGFloat,
    labelSize: CGFloat,
    style: WidgetStyleConfig
  ) -> some View {
    VStack(spacing: 2) {
      Text(String(format: "%02d", value))
        .font(.system(size: valueSize, weight: .bold, design: .rounded))
        .foregroundStyle(style.themeColor)
        .minimumScaleFactor(0.5)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
      Text(label)
        .font(.system(size: labelSize, weight: .semibold))
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity)
  }

  private static func colon(size: CGFloat, style: WidgetStyleConfig) -> some View {
    Text(":")
      .font(.system(size: size, weight: .bold, design: .rounded))
      .foregroundStyle(style.themeColor)
      .padding(.top, 1)
      .frame(width: size * 0.55)
  }
}
