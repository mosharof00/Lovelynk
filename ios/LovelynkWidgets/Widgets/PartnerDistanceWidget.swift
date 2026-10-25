import WidgetKit
import SwiftUI

// MARK: - Entry

struct PartnerDistanceEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
    let lockMessage: String
    let miles: Int
    let unit: String
    let userInitial: String
    let partnerInitial: String
    let isSharing: Bool
    let updatedAt: Date?
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct PartnerDistanceProvider: TimelineProvider {
    func placeholder(in context: Context) -> PartnerDistanceEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (PartnerDistanceEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PartnerDistanceEntry>) -> Void) {
        let entry = readEntry()
        // Phase 8: Timeline reload policy 30-60 min
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func readEntry() -> PartnerDistanceEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )
        let miles = AppGroupStore.int(WidgetKeys.PartnerDistance.miles, default: 0)
        let unit = AppGroupStore.string(WidgetKeys.PartnerDistance.unit, default: "mi")
        let user = AppGroupStore.string(WidgetKeys.PartnerDistance.userInitial, default: "—")
        let partner = AppGroupStore.string(WidgetKeys.PartnerDistance.partnerInitial, default: "—")
        let isSharing = AppGroupStore.string(WidgetKeys.PartnerDistance.isSharing, default: "1") != "0"
        let updatedAt = AppGroupStore.isoDate(WidgetKeys.PartnerDistance.updatedAt)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.PartnerDistance.widgetId)

        return PartnerDistanceEntry(
            date: Date(),
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            miles: miles,
            unit: unit,
            userInitial: user.isEmpty ? "—" : user,
            partnerInitial: partner.isEmpty ? "—" : partner,
            isSharing: isSharing,
            updatedAt: updatedAt,
            style: style
        )
    }

    private func sampleEntry() -> PartnerDistanceEntry {
        PartnerDistanceEntry(
            date: Date(),
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            miles: 168,
            unit: "mi",
            userInitial: "—",
            partnerInitial: "—",
            isSharing: true,
            updatedAt: Date(),
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.PartnerDistance.widgetId)
        )
    }
}

// MARK: - Views

struct PartnerDistanceWidgetView: View {
    var entry: PartnerDistanceEntry
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
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.PartnerDistance.widgetId))
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
                Image(systemName: "heart.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                if !entry.isSharing {
                    Text("Paused")
                        .font(.system(size: 10, weight: .bold))
                } else if entry.miles <= 0 {
                    Text("Together")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .privacySensitive()
                } else {
                    Text("\(entry.miles) \(entry.unit)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .minimumScaleFactor(0.55)
                        .lineLimit(1)
                        .privacySensitive()
                }
            }
        case .accessoryRectangular:
            accessoryRectangularLayout
        case .accessoryInline:
            if !entry.isSharing {
                Text("Location paused")
            } else if entry.miles <= 0 {
                Text("We're together!")
                    .privacySensitive()
            } else {
                Text("\(entry.miles) \(entry.unit) apart")
                    .privacySensitive()
            }
        case .systemMedium:
            competitorLayout(circleSize: 36, heartSize: 28, titleSize: entry.style.homeTitleSize(for: family) + 2)
        default:
            competitorLayout(circleSize: 30, heartSize: 24, titleSize: entry.style.homeTitleSize(for: family))
        }
    }

    /// Lock rectangular: compact competitor-style track.
    private var accessoryRectangularLayout: some View {
        VStack(alignment: .leading, spacing: 3) {
            if !entry.isSharing {
                Text("Location sharing paused")
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
            } else if entry.miles <= 0 {
                Text("We're together!")
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .privacySensitive()
            } else {
                Text("Our distance: \(entry.miles) \(entry.unit)")
                    .font(.system(size: 12, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .privacySensitive()
            }
            distanceConnectionRow(circleSize: 20, heartSize: 14, lineColor: .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    /// Home screen layout: title + initials connected by a single heart.
    private func competitorLayout(
        circleSize: CGFloat,
        heartSize: CGFloat,
        titleSize: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            if !entry.isSharing {
                Text("Location sharing paused")
                    .font(.system(size: titleSize, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            } else if entry.miles <= 0 {
                Text("We're together!")
                    .font(.system(size: titleSize, weight: .semibold))
                    .foregroundStyle(entry.style.themeColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
                    .privacySensitive()
            } else {
                Text("Our distance: \(entry.miles) \(entry.unit == "mi" ? "miles" : "km")")
                    .font(.system(size: titleSize, weight: .semibold))
                    .foregroundStyle(entry.style.themeColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                    .frame(maxWidth: .infinity)
                    .privacySensitive()
            }

            Spacer(minLength: 8)

            distanceConnectionRow(
                circleSize: circleSize,
                heartSize: heartSize,
                lineColor: entry.style.themeColor
            )

            Spacer(minLength: 4)

            if let updated = entry.updatedAt, entry.isSharing {
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                    Text(updated, style: .relative)
                        .font(.system(size: 10))
                    Text("ago")
                        .font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
                .privacySensitive()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private func distanceConnectionRow(
        circleSize: CGFloat,
        heartSize: CGFloat,
        lineColor: Color
    ) -> some View {
        HStack(spacing: 0) {
            initialCircle(entry.userInitial, size: circleSize, color: lineColor)

            connectionLine(color: lineColor)

            Image(systemName: "heart.fill")
                .font(.system(size: heartSize * 0.72, weight: .semibold))
                .foregroundStyle(lineColor)
                .frame(width: heartSize, height: heartSize)
                .padding(.horizontal, 4)
                .widgetAccentable()

            connectionLine(color: lineColor)

            initialCircle(entry.partnerInitial, size: circleSize, color: lineColor)
        }
        .frame(maxWidth: .infinity)
    }

    private func connectionLine(color: Color) -> some View {
        Rectangle()
            .fill(color.opacity(0.55))
            .frame(height: 1.5)
            .frame(maxWidth: .infinity)
    }

    private func initialCircle(_ initial: String, size: CGFloat, color: Color) -> some View {
        Text(initial)
            .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .privacySensitive()
            .background(
                Circle()
                    .fill(color.opacity(0.12))
            )
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 1.5)
            )
    }
}

// MARK: - Widget definition

struct PartnerDistanceWidget: Widget {
    let kind: String = "PartnerDistanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PartnerDistanceProvider()) { entry in
            PartnerDistanceWidgetView(entry: entry)
        }
        .configurationDisplayName("Partner Distance")
        .description("How far apart you and your partner are.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
