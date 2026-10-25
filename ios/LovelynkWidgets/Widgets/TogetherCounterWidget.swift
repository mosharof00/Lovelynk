import WidgetKit
import SwiftUI

// MARK: - Entry

struct TogetherCounterEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
    let lockMessage: String
    let hasDate: Bool
    let since: Date
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct TogetherCounterProvider: TimelineProvider {
    func placeholder(in context: Context) -> TogetherCounterEntry {
        sampleEntry(at: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (TogetherCounterEntry) -> Void) {
        completion(readEntry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TogetherCounterEntry>) -> Void) {
        let now = Date()
        var entries: [TogetherCounterEntry] = []
        for secondOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: now)!
            entries.append(readEntry(at: entryDate))
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    private func readEntry(at date: Date) -> TogetherCounterEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )

        let parsedSince = AppGroupStore.isoDate(WidgetKeys.TogetherCounter.since)
            ?? AppGroupStore.isoDate(WidgetKeys.DaysTogether.since)
        let hasDate = parsedSince != nil
        let since = parsedSince ?? date
        let parts = WidgetTimeMath.durationComponents(from: since, to: date)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.TogetherCounter.widgetId)

        return TogetherCounterEntry(
            date: date,
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            hasDate: hasDate,
            since: since,
            days: parts.days,
            hours: parts.hours,
            minutes: parts.minutes,
            seconds: parts.seconds,
            style: style
        )
    }

    private func sampleEntry(at date: Date) -> TogetherCounterEntry {
        let since = Calendar.current.date(byAdding: .day, value: -76, to: date) ?? date
        let parts = WidgetTimeMath.durationComponents(from: since, to: date)
        return TogetherCounterEntry(
            date: date,
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            hasDate: true,
            since: since,
            days: parts.days,
            hours: parts.hours,
            minutes: parts.minutes,
            seconds: parts.seconds,
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.TogetherCounter.widgetId)
        )
    }
}

// MARK: - Views

struct TogetherCounterWidgetView: View {
    var entry: TogetherCounterEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if entry.isLocked {
                lockedView
            } else if !entry.isPaired {
                unpairedView
            } else if !entry.hasDate {
                emptyDateView
            } else {
                contentView
            }
        }
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.TogetherCounter.widgetId))
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
    private var emptyDateView: some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 0) {
                Image(systemName: "calendar.badge.plus")
                    .font(.caption)
                Text("Start").font(.caption2)
            }
        case .accessoryRectangular:
            HStack {
                Image(systemName: "calendar.badge.plus")
                Text("Set relationship start").font(.headline).lineLimit(1)
            }
        case .accessoryInline:
            Text("♥ Set relationship start date")
        default:
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text("Together Since")
                    .font(.headline)
                Text("Tap to set date in app")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(WidgetLayoutMetrics.homePadding)
        }
    }

    private var counterLine: String {
        String(
            format: "%02d:%02d:%02d:%02d",
            entry.days,
            entry.hours,
            entry.minutes,
            entry.seconds
        )
    }

    @ViewBuilder
    private var contentView: some View {
        switch family {
        case .accessoryCircular:
            WidgetCountdownLayout.accessoryCircular(
                days: entry.days,
                hours: entry.hours,
                minutes: entry.minutes,
                seconds: entry.seconds,
                title: "Together"
            )
        case .accessoryRectangular:
            WidgetCountdownLayout.accessoryRectangular(
                days: entry.days,
                hours: entry.hours,
                minutes: entry.minutes,
                seconds: entry.seconds,
                title: "Together for"
            )
        case .accessoryInline:
            Text("Together \(counterLine)")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 0) {
            Text("Together")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            WidgetCountdownLayout.smallGrid(
                days: entry.days,
                hours: entry.hours,
                minutes: entry.minutes,
                seconds: entry.seconds,
                style: entry.style,
                family: family
            )

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        VStack(spacing: 0) {
            Text("Together for")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            WidgetCountdownLayout.mediumRow(
                days: entry.days,
                hours: entry.hours,
                minutes: entry.minutes,
                seconds: entry.seconds,
                style: entry.style,
                family: family
            )

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }
}

// MARK: - Widget definition

struct TogetherCounterWidget: Widget {
    let kind: String = "TogetherCounterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TogetherCounterProvider()) { entry in
            TogetherCounterWidgetView(entry: entry)
        }
        .configurationDisplayName("Together Counter")
        .description("Live count of your time together.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
