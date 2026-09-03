import WidgetKit
import SwiftUI

// MARK: - Entry

struct DaysTogetherEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    let count: Int
    let title: String
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct DaysTogetherProvider: TimelineProvider {
    func placeholder(in context: Context) -> DaysTogetherEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (DaysTogetherEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DaysTogetherEntry>) -> Void) {
        let entry = readEntry()
        // Midnight refresh so day count stays accurate.
        let nextMidnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func readEntry() -> DaysTogetherEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let count = AppGroupStore.int(WidgetKeys.DaysTogether.count, default: 0)
        let title = AppGroupStore.string(
            WidgetKeys.DaysTogether.title,
            default: "Days Together"
        )
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.DaysTogether.widgetId)
        return DaysTogetherEntry(
            date: Date(),
            isLocked: locked,
            lockMessage: lockMessage,
            count: count,
            title: title,
            style: style
        )
    }

    private func sampleEntry() -> DaysTogetherEntry {
        DaysTogetherEntry(
            date: Date(),
            isLocked: false,
            lockMessage: "Locked",
            count: 76,
            title: "Days Together",
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.DaysTogether.widgetId)
        )
    }
}

// MARK: - Views

struct DaysTogetherWidgetView: View {
    var entry: DaysTogetherEntry
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
                Image(systemName: "lock.fill")
                    .font(.title2)
                Text(entry.lockMessage)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 0) {
                Text("❤️").font(.caption2)
                Text("\(entry.count)").font(.headline)
            }
        case .accessoryRectangular:
            HStack {
                Text("❤️")
                Text("\(entry.count) days").font(.headline)
            }
        case .accessoryInline:
            Text("❤️ \(entry.count) days")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(entry.title)
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Spacer(minLength: 4)

            Text("\(entry.count)")
                .font(entry.style.homeValueFont(for: family))
                .foregroundStyle(entry.style.themeColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text("days")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .regular))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(entry.count)")
                        .font(entry.style.homeValueFont(for: family))
                        .foregroundStyle(entry.style.themeColor)
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("days")
                        .font(.system(
                            size: entry.style.homeTitleSize(for: family) + 4,
                            weight: .medium
                        ))
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 0)

            Text("❤️")
                .font(.system(size: entry.style.homeValueSize(for: family) * 0.72))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }
}

// MARK: - Widget definition

struct DaysTogetherWidget: Widget {
    let kind: String = "DaysTogetherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DaysTogetherProvider()) { entry in
            DaysTogetherWidgetView(entry: entry)
        }
        .configurationDisplayName("Days Together")
        .description("How many days you've been together.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
