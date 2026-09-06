import WidgetKit
import SwiftUI

// MARK: - Entry

struct HeartbeatEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    let count: Int
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct HeartbeatProvider: TimelineProvider {
    func placeholder(in context: Context) -> HeartbeatEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (HeartbeatEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HeartbeatEntry>) -> Void) {
        let entry = readEntry()
        completion(Timeline(entries: [entry], policy: .never))
    }

    private func readEntry() -> HeartbeatEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let count = AppGroupStore.int(WidgetKeys.Heartbeat.count, default: 0)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.Heartbeat.widgetId)
        return HeartbeatEntry(
            date: Date(),
            isLocked: locked,
            lockMessage: lockMessage,
            count: count,
            style: style
        )
    }

    private func sampleEntry() -> HeartbeatEntry {
        HeartbeatEntry(
            date: Date(),
            isLocked: false,
            lockMessage: "Locked",
            count: 90,
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.Heartbeat.widgetId)
        )
    }
}

// MARK: - Views

struct HeartbeatWidgetView: View {
    var entry: HeartbeatEntry
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
        .widgetURL(WidgetDeepLinks.heartbeat)
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
                Image(systemName: "waveform.path.ecg")
                    .font(.caption2)
                    .foregroundStyle(entry.style.themeColor)
                Text("\(entry.count)").font(.headline)
            }
        case .accessoryRectangular:
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(entry.style.themeColor)
                Text("\(entry.count) heartbeats").font(.headline)
            }
        case .accessoryInline:
            Text("💓 \(entry.count) from partner")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 6) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: entry.style.homeValueSize(for: family) * 0.55))
                .foregroundStyle(entry.style.themeColor)
            Text("\(entry.count)")
                .font(entry.style.homeValueFont(for: family))
                .foregroundStyle(entry.style.themeColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Text("from partner")
                .font(.system(size: entry.style.homeTitleSize(for: family)))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        HStack(spacing: 16) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: entry.style.homeValueSize(for: family) * 0.72))
                .foregroundStyle(entry.style.themeColor)
            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.count)")
                    .font(entry.style.homeValueFont(for: family))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("heartbeats from partner")
                    .font(.system(size: entry.style.homeTitleSize(for: family)))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }
}

// MARK: - Widget definition

struct HeartbeatWidget: Widget {
    let kind: String = "HeartbeatWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HeartbeatProvider()) { entry in
            HeartbeatWidgetView(entry: entry)
        }
        .configurationDisplayName("Heartbeat")
        .description("Heartbeats your partner sent you. Tap to send one back.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
