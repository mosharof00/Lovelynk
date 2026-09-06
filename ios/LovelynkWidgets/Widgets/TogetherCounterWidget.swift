import WidgetKit
import SwiftUI

// MARK: - Entry

struct TogetherCounterEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    /// Relationship start — OS timer counts up from this date every second.
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
        let entry = readEntry(at: Date())
        // Rare reload — live seconds come from Text(_:style: .timer), not timeline entries.
        let refresh = Calendar.current.date(byAdding: .hour, value: 6, to: Date()) ?? Date().addingTimeInterval(21_600)
        completion(Timeline(entries: [entry], policy: .after(refresh)))
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
            WidgetLiveTimer.countUp(
                from: entry.since,
                font: .system(size: 12, weight: .bold, design: .rounded)
            )
            .minimumScaleFactor(0.4)
        case .accessoryRectangular:
            accessoryRectangularLayout
        case .accessoryInline:
            HStack(spacing: 4) {
                Text("Together")
                WidgetLiveTimer.countUp(
                    from: entry.since,
                    font: .body.weight(.semibold)
                )
            }
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var accessoryRectangularLayout: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Together for")
                .font(.system(size: 12, weight: .medium))
                .lineLimit(1)
            WidgetLiveTimer.countUp(
                from: entry.since,
                font: .system(size: 20, weight: .bold, design: .rounded)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var smallLayout: some View {
        VStack(spacing: 0) {
            Text("Together")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            WidgetLiveTimer.countUp(
                from: entry.since,
                font: .system(
                    size: entry.style.homeValueSize(for: family) * 0.42,
                    weight: .bold,
                    design: .rounded
                ),
                color: entry.style.themeColor
            )
            .frame(maxWidth: .infinity)

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

            WidgetLiveTimer.countUp(
                from: entry.since,
                font: .system(
                    size: entry.style.homeValueSize(for: family) * 0.55,
                    weight: .bold,
                    design: .rounded
                ),
                color: entry.style.themeColor
            )
            .frame(maxWidth: .infinity)

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
