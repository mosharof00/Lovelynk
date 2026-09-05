import WidgetKit
import SwiftUI

// MARK: - Entry

struct TogetherCounterEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
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
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let since = AppGroupStore.isoDate(WidgetKeys.TogetherCounter.since) ?? date
        let parts = WidgetTimeMath.durationComponents(from: since, to: date)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.TogetherCounter.widgetId)

        return TogetherCounterEntry(
            date: date,
            isLocked: locked,
            lockMessage: lockMessage,
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
            lockMessage: "Locked",
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
            VStack(spacing: 0) {
                Text("\(entry.days)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("days")
                    .font(.system(size: 9, weight: .medium))
            }
        case .accessoryRectangular:
            WidgetCountdownLayout.accessoryRectangular(
                days: entry.days,
                hours: entry.hours,
                minutes: entry.minutes,
                seconds: entry.seconds
            )
        case .accessoryInline:
            Text("Together \(counterLine)")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
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
            Text("Together Counter")
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
