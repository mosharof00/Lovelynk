import WidgetKit
import SwiftUI

// MARK: - Entry

struct LoveCompassEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
    let lockMessage: String
    let miles: Int
    let direction: String
    let bearing: Double
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
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func readEntry() -> LoveCompassEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )
        // Phase 8: Neutral fallbacks, no hardcoded "Milla" or "213 mi"
        let miles = AppGroupStore.int(WidgetKeys.LoveCompass.miles, default: 0)
        let bearing = AppGroupStore.double(WidgetKeys.LoveCompass.bearing, default: AppGroupStore.double(WidgetKeys.LoveCompass.needleDegrees, default: 0))
        let direction = AppGroupStore.string(WidgetKeys.LoveCompass.direction, default: "N")
        let partnerName = AppGroupStore.string(WidgetKeys.partnerName, default: "Partner")
        let partnerLabel = AppGroupStore.string(
            WidgetKeys.LoveCompass.partnerLabel,
            default: partnerName.isEmpty ? "Partner" : partnerName
        )
        let needle = AppGroupStore.double(
            WidgetKeys.LoveCompass.needleDegrees,
            default: bearing
        )
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.LoveCompass.widgetId)

        return LoveCompassEntry(
            date: Date(),
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            miles: miles,
            direction: direction,
            bearing: bearing,
            partnerLabel: partnerLabel,
            needleDegrees: needle,
            style: style
        )
    }

    private func sampleEntry() -> LoveCompassEntry {
        LoveCompassEntry(
            date: Date(),
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            miles: 168,
            direction: "NE",
            bearing: 45,
            partnerLabel: "Partner",
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
            } else if !entry.isPaired {
                unpairedView
            } else {
                contentView
            }
        }
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.LoveCompass.widgetId))
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
                Text(entry.lockMessage).font(.headline).lineLimit(1)
            }
        case .accessoryInline:
            Text("🔒 \(entry.lockMessage)").lineLimit(1)
        default:
            VStack(spacing: 6) {
                Image(systemName: "lock.fill").font(.title2)
                Text(entry.lockMessage).font(.headline).multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var unpairedView: some View {
        switch family {
        case .accessoryCircular:
            Image(systemName: "person.crop.circle.badge.plus")
        case .accessoryRectangular:
            HStack {
                Image(systemName: "person.crop.circle.badge.plus")
                Text("Connect Partner").font(.caption).bold().lineLimit(1)
            }
        case .accessoryInline:
            Text("Connect Partner in LoveLynk")
        default:
            VStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.title)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text("Connect Partner")
                    .font(.headline)
                Text("Tap to pair")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(WidgetLayoutMetrics.homePadding)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 0) {
                Image(systemName: "location.north.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(entry.style.themeColor)
                    .rotationEffect(.degrees(entry.needleDegrees))
                    .widgetAccentable()
                Text("\(entry.miles) mi")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .lineLimit(1)
                    .privacySensitive()
            }
        case .accessoryRectangular:
            HStack(spacing: 8) {
                CompassDialView(
                    needleDegrees: entry.needleDegrees,
                    size: 42,
                    color: .primary
                )
                .widgetAccentable()

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.partnerLabel)
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(1)
                        .privacySensitive()
                    Text("\(entry.direction) \(Int(entry.bearing))°")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .lineLimit(1)
                    Text("\(entry.miles) miles")
                        .font(.system(size: 11, weight: .regular))
                        .lineLimit(1)
                        .privacySensitive()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        case .accessoryInline:
            Text("🧭 \(entry.direction) \(entry.miles) mi to \(entry.partnerLabel)")
                .privacySensitive()
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 4) {
            Text(entry.partnerLabel)
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .privacySensitive()

            Spacer(minLength: 0)

            CompassDialView(
                needleDegrees: entry.needleDegrees,
                size: 68,
                color: entry.style.themeColor
            )
            .widgetAccentable()

            Spacer(minLength: 0)

            VStack(spacing: 1) {
                Text("\(entry.direction) · \(entry.miles) mi")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(entry.style.themeColor)
                    .lineLimit(1)
                    .privacySensitive()

                Text("Bearing \(Int(entry.bearing))° N")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        HStack(spacing: 16) {
            CompassDialView(
                needleDegrees: entry.needleDegrees,
                size: 96,
                color: entry.style.themeColor
            )
            .widgetAccentable()

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.partnerLabel)
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .privacySensitive()

                Text("\(entry.direction) · \(entry.miles) miles")
                    .font(entry.style.homeValueFont(for: family))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .privacySensitive()

                Text("Direction from True North: \(Int(entry.bearing))°")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
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
        .description("Points the direction and distance toward where your partner is.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
