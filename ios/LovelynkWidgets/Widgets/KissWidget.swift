import WidgetKit
import SwiftUI

// MARK: - Entry

struct KissEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    let count: Int
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct KissProvider: TimelineProvider {
    func placeholder(in context: Context) -> KissEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (KissEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KissEntry>) -> Void) {
        let entry = readEntry()
        completion(Timeline(entries: [entry], policy: .never))
    }

    private func readEntry() -> KissEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let count = AppGroupStore.int(WidgetKeys.Kiss.count, default: 0)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.Kiss.widgetId)
        return KissEntry(
            date: Date(),
            isLocked: locked,
            lockMessage: lockMessage,
            count: count,
            style: style
        )
    }

    private func sampleEntry() -> KissEntry {
        KissEntry(
            date: Date(),
            isLocked: false,
            lockMessage: "Locked",
            count: 42,
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.Kiss.widgetId)
        )
    }
}

// MARK: - Views

struct KissWidgetView: View {
    var entry: KissEntry
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
        .widgetURL(WidgetDeepLinks.kiss)
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
                Text("💋").font(.caption2)
                Text("\(entry.count)").font(.headline)
            }
        case .accessoryRectangular:
            HStack {
                Text("💋")
                Text("\(entry.count) kisses").font(.headline)
            }
        case .accessoryInline:
            Text("💋 \(entry.count) from partner")
        case .systemMedium:
            mediumLayout
        default:
            compactHomeLayout
        }
    }

    private var compactHomeLayout: some View {
        VStack(spacing: 4) {
            Text("💋")
                .font(.system(size: entry.style.homeValueSize(for: family) * 0.60))
            Text("\(entry.count)")
                .font(.system(
                    size: entry.style.homeValueSize(for: family) * 0.42,
                    weight: .bold,
                    design: .rounded
                ))
                .foregroundStyle(entry.style.themeColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text("from partner")
                .font(.system(size: entry.style.homeTitleSize(for: family) * 0.85))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
        .widgetBackground(entry.style)
    }

    private var mediumLayout: some View {
        HStack(spacing: 16) {
            Text("💋")
                .font(.system(size: entry.style.homeValueSize(for: family) * 0.80))
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.count)")
                    .font(entry.style.homeValueFont(for: family))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("kisses from partner")
                    .font(.system(size: entry.style.homeTitleSize(for: family)))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
        .widgetBackground(entry.style)
    }
}

// MARK: - Widget definition

struct KissWidget: Widget {
    let kind: String = "KissWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: KissProvider()) { entry in
            KissWidgetView(entry: entry)
        }
        .configurationDisplayName("Kiss")
        .description("Kisses your partner sent you. Tap to send one back.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
