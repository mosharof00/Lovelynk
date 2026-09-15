import WidgetKit
import SwiftUI

// MARK: - Entry

struct TogetherCounterEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    /// Relationship start — elapsed D/H/M/S computed against [date].
    let since: Date
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
        // Tick seconds for ~1 minute, then WidgetKit reloads.
        for secondOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: now) ?? now
            entries.append(readEntry(at: entryDate))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func readEntry(at date: Date) -> TogetherCounterEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let since = AppGroupStore.isoDate(WidgetKeys.TogetherCounter.since) ?? date
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.TogetherCounter.widgetId)

        return TogetherCounterEntry(
            date: date,
            isLocked: locked,
            lockMessage: lockMessage,
            since: since,
            style: style
        )
    }

    private func sampleEntry(at date: Date) -> TogetherCounterEntry {
        let since = Calendar.current.date(byAdding: .day, value: -76, to: date) ?? date
        return TogetherCounterEntry(
            date: date,
            isLocked: false,
            lockMessage: "Locked",
            since: since,
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.TogetherCounter.widgetId)
        )
    }
}

// MARK: - Views

struct TogetherCounterWidgetView: View {
    var entry: TogetherCounterEntry
    @Environment(\.widgetFamily) var family

    private var parts: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        WidgetTimeMath.durationComponents(from: entry.since, to: entry.date)
    }

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
        let p = parts
        switch family {
        case .accessoryCircular:
            WidgetCountdownLayout.accessoryCircular(
                days: p.days,
                hours: p.hours,
                minutes: p.minutes,
                seconds: p.seconds,
                title: "Together"
            )
        case .accessoryRectangular:
            WidgetCountdownLayout.accessoryRectangular(
                days: p.days,
                hours: p.hours,
                minutes: p.minutes,
                seconds: p.seconds,
                title: "Together for"
            )
        case .accessoryInline:
            Text("Together \(p.days)d \(p.hours)h \(p.minutes)m")
                .font(.body.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        case .systemMedium:
            mediumLayout(p)
        default:
            smallLayout(p)
        }
    }

    private func smallLayout(
        _ p: (days: Int, hours: Int, minutes: Int, seconds: Int)
    ) -> some View {
        VStack(spacing: 0) {
            Text("Together")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 4)

            WidgetCountdownLayout.smallGrid(
                days: p.days,
                hours: p.hours,
                minutes: p.minutes,
                seconds: p.seconds,
                style: entry.style,
                family: family
            )

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private func mediumLayout(
        _ p: (days: Int, hours: Int, minutes: Int, seconds: Int)
    ) -> some View {
        VStack(spacing: 0) {
            Text("Together for")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 4)

            WidgetCountdownLayout.mediumRow(
                days: p.days,
                hours: p.hours,
                minutes: p.minutes,
                seconds: p.seconds,
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
