import WidgetKit
import SwiftUI

// MARK: - Entry

struct PartnerTimeEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
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
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: now)!
            entries.append(readEntry(at: entryDate))
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func readEntry(at date: Date) -> PartnerTimeEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let offset = AppGroupStore.int(WidgetKeys.PartnerTime.utcOffsetHours, default: 10)
        let city = AppGroupStore.string(WidgetKeys.PartnerTime.city, default: "Sydney, Australia")
        let clock = WidgetTimeMath.partnerClock(at: date, offsetHours: offset)
        let formatted = WidgetTimeMath.format12Hour(hour: clock.hour, minute: clock.minute)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.PartnerTime.widgetId)

        return PartnerTimeEntry(
            date: date,
            isLocked: locked,
            lockMessage: lockMessage,
            timeText: formatted.time,
            period: formatted.period,
            city: city,
            style: style
        )
    }

    private func sampleEntry(at date: Date) -> PartnerTimeEntry {
        let clock = WidgetTimeMath.partnerClock(at: date, offsetHours: 10)
        let formatted = WidgetTimeMath.format12Hour(hour: clock.hour, minute: clock.minute)
        return PartnerTimeEntry(
            date: date,
            isLocked: false,
            lockMessage: "Locked",
            timeText: formatted.time,
            period: formatted.period,
            city: "Sydney, Australia",
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
            } else {
                contentView
            }
        }
        .accessoryWidgetContainer(family: family)
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
            Text(entry.timeText)
                    .font(.caption)
                    .minimumScaleFactor(0.7)
        case .accessoryRectangular:
            HStack {
                Image(systemName: "clock.fill")
                Text("\(entry.timeText) \(entry.period)").font(.headline)
            }
        case .accessoryInline:
            Text("🕐 \(entry.timeText) \(entry.period)")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 0) {
            Text("Partner Time")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            timeDisplay(compact: true)

            Spacer(minLength: 4)

            cityRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
        .widgetBackground(entry.style)
    }

    private var mediumLayout: some View {
        VStack(spacing: 0) {
            Text("Partner Time")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            timeDisplay(compact: false)

            Spacer(minLength: 6)

            cityRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
        .widgetBackground(entry.style)
    }

    private func timeDisplay(compact: Bool) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 4) {
            Text(entry.timeText)
                .font(.system(
                    size: compact
                        ? entry.style.homeValueSize(for: family) * 0.85
                        : entry.style.homeValueSize(for: family),
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundStyle(entry.style.themeColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text(entry.period)
                .font(.system(
                    size: compact
                        ? entry.style.homeTitleSize(for: family)
                        : entry.style.homeTitleSize(for: family) + 2,
                    weight: .semibold
                ))
                .foregroundStyle(entry.style.themeColor)
        }
        .frame(maxWidth: .infinity)
    }

    private var cityRow: some View {
        HStack(spacing: 3) {
            Image(systemName: "location.fill")
                .font(.system(size: entry.style.homeTitleSize(for: family) - 1))
            Text(entry.city)
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .regular))
                .lineLimit(1)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
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
        .description("Your partner's local time.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
