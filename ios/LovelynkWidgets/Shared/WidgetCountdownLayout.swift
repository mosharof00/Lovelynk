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
        counterUnit(days, label: "D", valueSize: valueSize, labelSize: labelSize, style: style, pad: false)
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
    // Wide day counts → short labels to avoid clipping.
    let compact = days >= 100
    let valueSize = style.homeValueSize(for: family) * (compact ? 0.40 : 0.48)
    let labelSize = style.homeTitleSize(for: family) - 2

    return HStack(alignment: .top, spacing: compact ? 2 : 4) {
      counterUnit(
        days,
        label: compact ? "D" : "DAY",
        valueSize: valueSize,
        labelSize: labelSize,
        style: style,
        pad: false
      )
      colon(size: valueSize, style: style)
      counterUnit(
        hours,
        label: compact ? "H" : "HOUR",
        valueSize: valueSize,
        labelSize: labelSize,
        style: style
      )
      colon(size: valueSize, style: style)
      counterUnit(
        minutes,
        label: compact ? "M" : "MIN",
        valueSize: valueSize,
        labelSize: labelSize,
        style: style
      )
      colon(size: valueSize, style: style)
      counterUnit(
        seconds,
        label: compact ? "S" : "SEC",
        valueSize: valueSize,
        labelSize: labelSize,
        style: style
      )
    }
    .frame(maxWidth: .infinity)
  }

  /// Lock-screen rectangular with title + labeled units (short letters when days are large).
  static func accessoryRectangular(
    days: Int,
    hours: Int,
    minutes: Int,
    seconds: Int,
    title: String = "Together for"
  ) -> some View {
    let compact = days >= 100
    let valueSize: CGFloat = compact ? 15 : 17
    let labelSize: CGFloat = 6.5
    let colonSize: CGFloat = compact ? 14 : 15
    let dayLabel = compact ? "D" : "DAYS"
    let hourLabel = compact ? "H" : "HOUR"
    let minLabel = compact ? "M" : "MIN"
    let secLabel = compact ? "S" : "SEC"

    return VStack(alignment: .leading, spacing: 1) {
      Text(title)
        .font(.system(size: 11, weight: .medium))
        .lineLimit(1)
        .minimumScaleFactor(0.7)

      HStack(alignment: .top, spacing: 0) {
        accessoryUnit(days, label: dayLabel, valueSize: valueSize, labelSize: labelSize, pad: false)
        accessoryColon(size: colonSize)
        accessoryUnit(hours, label: hourLabel, valueSize: valueSize, labelSize: labelSize)
        accessoryColon(size: colonSize)
        accessoryUnit(minutes, label: minLabel, valueSize: valueSize, labelSize: labelSize)
        accessoryColon(size: colonSize)
        accessoryUnit(seconds, label: secLabel, valueSize: valueSize, labelSize: labelSize)
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .minimumScaleFactor(0.55)
      .lineLimit(1)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
  }

  /// Lock-screen circular: title + compact D : H / M : S.
  static func accessoryCircular(
    days: Int,
    hours: Int,
    minutes: Int,
    seconds: Int,
    title: String = "Together"
  ) -> some View {
    let wideDays = days >= 100
    let valueSize: CGFloat = wideDays ? 9 : 11
    let labelSize: CGFloat = 6

    return VStack(spacing: 1) {
      Text(title)
        .font(.system(size: 8, weight: .semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.6)

      HStack(spacing: 0) {
        accessoryUnit(days, label: "D", valueSize: valueSize, labelSize: labelSize, pad: false)
        accessoryColon(size: valueSize)
        accessoryUnit(hours, label: "H", valueSize: valueSize, labelSize: labelSize)
      }
      HStack(spacing: 0) {
        accessoryUnit(minutes, label: "M", valueSize: valueSize, labelSize: labelSize)
        accessoryColon(size: valueSize)
        accessoryUnit(seconds, label: "S", valueSize: valueSize, labelSize: labelSize)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .minimumScaleFactor(0.55)
  }

  private static func counterUnit(
    _ value: Int,
    label: String,
    valueSize: CGFloat,
    labelSize: CGFloat,
    style: WidgetStyleConfig,
    pad: Bool = true
  ) -> some View {
    VStack(spacing: 2) {
      Text(pad ? String(format: "%02d", value) : "\(value)")
        .font(.system(size: valueSize, weight: .bold, design: .rounded))
        .foregroundStyle(style.themeColor)
        .minimumScaleFactor(0.4)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
      Text(label)
        .font(.system(size: labelSize, weight: .semibold))
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
        .frame(maxWidth: .infinity)
    }
    .frame(maxWidth: .infinity)
  }

  private static func colon(size: CGFloat, style: WidgetStyleConfig) -> some View {
    Text(":")
      .font(.system(size: size, weight: .bold, design: .rounded))
      .foregroundStyle(style.themeColor)
      .padding(.top, 1)
      .frame(width: size * 0.45)
  }

  private static func accessoryUnit(
    _ value: Int,
    label: String,
    valueSize: CGFloat,
    labelSize: CGFloat,
    pad: Bool = true
  ) -> some View {
    VStack(spacing: 0) {
      Text(pad ? String(format: "%02d", value) : "\(value)")
        .font(.system(size: valueSize, weight: .bold, design: .rounded))
        .monospacedDigit()
        .minimumScaleFactor(0.4)
        .lineLimit(1)
      Text(label)
        .font(.system(size: labelSize, weight: .semibold))
        .lineLimit(1)
        .minimumScaleFactor(0.6)
    }
    .frame(minWidth: 0)
  }

  private static func accessoryColon(size: CGFloat) -> some View {
    Text(":")
      .font(.system(size: size, weight: .bold, design: .rounded))
      .padding(.top, 0)
      .frame(width: max(5, size * 0.4))
  }
}
