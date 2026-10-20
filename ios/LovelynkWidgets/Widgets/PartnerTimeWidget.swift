import WidgetKit
import SwiftUI

// MARK: - Entry

struct PartnerTimeEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
    let lockMessage: String
    let timeText: String
    let period: String
    let city: String
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct PartnerTimeProvider: TimelineProvider {
    func placeholder(in context: Context) -> PartnerTimeEntry {
        sampleEntry(at: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (PartnerTimeEntry) -> Void) {
        completion(readEntry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PartnerTimeEntry>) -> Void) {
        let now = Date()
        var entries: [PartnerTimeEntry] = []
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: now) ?? now
            entries.append(readEntry(at: entryDate))
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func readEntry(at date: Date) -> PartnerTimeEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )
        // Phase 8: Neutral fallback, no hardcoded "Sydney"
        let city = AppGroupStore.string(WidgetKeys.PartnerTime.city, default: isPaired ? "Partner's Time" : "—")

        let clock: (hour: Int, minute: Int)
        let tzStr = AppGroupStore.string(WidgetKeys.PartnerTime.timezone)
        if !tzStr.isEmpty, let zone = TimeZone(identifier: tzStr) {
            clock = WidgetTimeMath.partnerClock(at: date, timeZone: zone)
        } else {
            let minutes = AppGroupStore.int(
                WidgetKeys.PartnerTime.utcOffsetMinutes,
                default: AppGroupStore.int(WidgetKeys.PartnerTime.utcOffsetHours, default: 0) * 60
            )
            clock = WidgetTimeMath.partnerClock(at: date, offsetMinutes: minutes)
        }
        let formatted = WidgetTimeMath.format12Hour(hour: clock.hour, minute: clock.minute)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.PartnerTime.widgetId)

        return PartnerTimeEntry(
            date: date,
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            timeText: formatted.time,
            period: formatted.period,
            city: city,
            style: style
        )
    }

    private func sampleEntry(at date: Date) -> PartnerTimeEntry {
        PartnerTimeEntry(
            date: date,
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            timeText: "10:30",
            period: "AM",
            city: "Partner's City",
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.PartnerTime.widgetId)
        )
    }
}

// MARK: - Views

struct PartnerTimeWidgetView: View {
    var entry: PartnerTimeEntry
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
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.PartnerTime.widgetId))
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
                Image(systemName: "clock.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text(entry.timeText)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .privacySensitive()
                Text(entry.period)
                    .font(.system(size: 9, weight: .bold))
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.city)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
                    .privacySensitive()
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(entry.timeText)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .privacySensitive()
                    Text(entry.period)
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        case .accessoryInline:
            Text("🕒 \(entry.city): \(entry.timeText) \(entry.period)")
                .privacySensitive()
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.city)
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .privacySensitive()

            Spacer(minLength: 4)

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(entry.timeText)
                    .font(entry.style.homeValueFont(for: family))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .privacySensitive()

                Text(entry.period)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(entry.style.themeColor)
            }

            Spacer(minLength: 4)

            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                Text("Partner's local time")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.city)
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .privacySensitive()

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(entry.timeText)
                        .font(entry.style.homeValueFont(for: family))
                        .foregroundStyle(entry.style.themeColor)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .privacySensitive()

                    Text(entry.period)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(entry.style.themeColor)
                }

                Text("Partner's current local time")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "clock.fill")
                .font(.system(size: 40))
                .foregroundStyle(entry.style.themeColor)
                .widgetAccentable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }
}

// MARK: - Widget definition

struct PartnerTimeWidget: Widget {
    let kind: String = "PartnerTimeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PartnerTimeProvider()) { entry in
            PartnerTimeWidgetView(entry: entry)
        }
        .configurationDisplayName("Partner Time")
        .description("Your partner's current local time.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
