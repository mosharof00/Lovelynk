import WidgetKit
import SwiftUI

// MARK: - Entry

struct LoveCompassEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    let miles: Int
    let partnerLabel: String
    let needleDegrees: Double
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct LoveCompassProvider: TimelineProvider {
    func placeholder(in context: Context) -> LoveCompassEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (LoveCompassEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<LoveCompassEntry>) -> Void) {
        let entry = readEntry()
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func readEntry() -> LoveCompassEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let miles = AppGroupStore.int(WidgetKeys.LoveCompass.miles, default: 213)
        let partnerLabel = AppGroupStore.string(
            WidgetKeys.LoveCompass.partnerLabel,
            default: "Milla"
        )
        let needle = AppGroupStore.double(
            WidgetKeys.LoveCompass.needleDegrees,
            default: 45
        )
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.LoveCompass.widgetId)

        return LoveCompassEntry(
            date: Date(),
            isLocked: locked,
            lockMessage: lockMessage,
            miles: miles,
            partnerLabel: partnerLabel,
            needleDegrees: needle,
            style: style
        )
    }

    private func sampleEntry() -> LoveCompassEntry {
        LoveCompassEntry(
            date: Date(),
            isLocked: false,
            lockMessage: "Locked",
            miles: 213,
            partnerLabel: "Milla",
            needleDegrees: 45,
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.LoveCompass.widgetId)
        )
    }
}

// MARK: - Views

struct LoveCompassWidgetView: View {
    var entry: LoveCompassEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if entry.isLocked {
                lockedView
            } else {
                contentView
            }
        }
        .lovelynkContainerBackground(style: entry.style, family: family)
    }

    @ViewBuilder
    private var lockedView: some View {
        switch family {
        case .accessoryCircular:
            Image(systemName: "lock.fill")
        case .accessoryRectangular:
            HStack {
                Image(systemName: "lock.fill")
                Text(entry.lockMessage).font(.headline)
            }
        case .accessoryInline:
            Text("🔒 \(entry.lockMessage)")
        default:
            VStack(spacing: 6) {
                Image(systemName: "lock.fill").font(.title2)
                Text(entry.lockMessage).font(.headline)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch family {
        case .accessoryCircular:
            // Mini dial so lock circular reads as a real compass, not just an arrow.
            CompassDialView(
                needleDegrees: entry.needleDegrees,
                size: 56,
                color: .primary
            )
        case .accessoryRectangular:
            HStack(spacing: 8) {
                CompassDialView(
                    needleDegrees: entry.needleDegrees,
                    size: 40,
                    color: .primary
                )
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(entry.miles) mi")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .lineLimit(1)
                    Text(entry.partnerLabel)
                        .font(.system(size: 12, weight: .medium))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        case .accessoryInline:
            Text("🧭 \(entry.miles)mi → \(entry.partnerLabel)")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var dialSize: CGFloat {
        switch family {
        case .systemMedium: return 88
        default: return 72
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 0) {
            Text("Love Compass")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            CompassDialView(
                needleDegrees: entry.needleDegrees,
                size: dialSize,
                color: entry.style.themeColor
            )

            Spacer(minLength: 4)

            Text("\(entry.miles) miles")
                .font(.system(
                    size: entry.style.homeTitleSize(for: family) + 1,
                    weight: .bold
                ))
                .foregroundStyle(entry.style.themeColor)

            Text("\(entry.partnerLabel) is this way")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .regular))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        HStack(spacing: 12) {
            CompassDialView(
                needleDegrees: entry.needleDegrees,
                size: dialSize,
                color: entry.style.themeColor
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Love Compass")
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                Text("\(entry.miles) miles")
                    .font(entry.style.homeValueFont(for: family))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)

                Text("\(entry.partnerLabel) is this way")
                    .font(.system(
                        size: entry.style.homeTitleSize(for: family) + 2,
                        weight: .medium
                    ))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }
}

// MARK: - Widget definition

struct LoveCompassWidget: Widget {
    let kind: String = "LoveCompassWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: LoveCompassProvider()) { entry in
            LoveCompassWidgetView(entry: entry)
        }
        .configurationDisplayName("Love Compass")
        .description("Points toward your partner.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
