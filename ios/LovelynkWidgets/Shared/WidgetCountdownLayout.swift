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

  /// Lock-screen rectangular: matches competitor "Together for / 47:10:03:29 / DAYS HOUR MIN SEC".
  static func accessoryRectangular(
    days: Int,
    hours: Int,
    minutes: Int,
    seconds: Int
  ) -> some View {
    let valueSize: CGFloat = 20
    let labelSize: CGFloat = 7
    let colonSize: CGFloat = 18

    return VStack(alignment: .leading, spacing: 1) {
      Text("Together for")
        .font(.system(size: 12, weight: .medium))
        .lineLimit(1)

      HStack(alignment: .top, spacing: 0) {
        accessoryUnit(days, label: "DAYS", valueSize: valueSize, labelSize: labelSize)
        accessoryColon(size: colonSize)
        accessoryUnit(hours, label: "HOUR", valueSize: valueSize, labelSize: labelSize)
        accessoryColon(size: colonSize)
        accessoryUnit(minutes, label: "MIN", valueSize: valueSize, labelSize: labelSize)
        accessoryColon(size: colonSize)
        accessoryUnit(seconds, label: "SEC", valueSize: valueSize, labelSize: labelSize)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
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

  private static func accessoryUnit(
    _ value: Int,
    label: String,
    valueSize: CGFloat,
    labelSize: CGFloat
  ) -> some View {
    VStack(spacing: 1) {
      Text(String(format: "%02d", value))
        .font(.system(size: valueSize, weight: .bold, design: .rounded))
        .monospacedDigit()
        .minimumScaleFactor(0.7)
        .lineLimit(1)
      Text(label)
        .font(.system(size: labelSize, weight: .semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
  }

  private static func accessoryColon(size: CGFloat) -> some View {
    Text(":")
      .font(.system(size: size, weight: .bold, design: .rounded))
      .padding(.top, 1)
      .frame(width: 8)
  }
}
