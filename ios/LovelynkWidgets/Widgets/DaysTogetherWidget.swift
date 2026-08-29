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
        if entry.isLocked {
            lockedView
        } else {
            contentView
        }
    }

    @ViewBuilder
    private var lockedView: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "lock.fill")
            }
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
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Text("❤️").font(.caption2)
                    Text("\(entry.count)").font(.headline)
                }
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
        VStack(spacing: 4) {
            Text(entry.title)
                .font(.system(size: entry.style.titleSize, weight: .medium))
                .foregroundStyle(.secondary)
            Text("\(entry.count)")
                .font(entry.style.font)
                .foregroundStyle(entry.style.themeColor)
            Text("days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .widgetBackground(entry.style)
    }

    private var mediumLayout: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.system(size: entry.style.titleSize, weight: .medium))
                    .foregroundStyle(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(entry.count)")
                        .font(entry.style.font)
                        .foregroundStyle(entry.style.themeColor)
                    Text("days")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Text("❤️")
                .font(.largeTitle)
        }
        .padding()
        .widgetBackground(entry.style)
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
