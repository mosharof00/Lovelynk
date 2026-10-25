import WidgetKit
import SwiftUI

// MARK: - Entry

struct HeartbeatEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
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
        // Phase 8: Refreshed by push payload or app sync; fallback to after 30 min
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func readEntry() -> HeartbeatEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )
        let count = AppGroupStore.int(WidgetKeys.Heartbeat.count, default: 0)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.Heartbeat.widgetId)

        return HeartbeatEntry(
            date: Date(),
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            count: count,
            style: style
        )
    }

    private func sampleEntry() -> HeartbeatEntry {
        HeartbeatEntry(
            date: Date(),
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            count: 24,
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
            } else if !entry.isPaired {
                unpairedView
            } else {
                contentView
            }
        }
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.Heartbeat.widgetId))
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
                Image(systemName: "waveform.path.ecg")
                    .font(.caption2)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text("\(entry.count)")
                    .font(.headline)
                    .privacySensitive()
            }
        case .accessoryRectangular:
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text("\(entry.count) heartbeats")
                    .font(.headline)
                    .privacySensitive()
            }
        case .accessoryInline:
            Text("💓 \(entry.count) from partner")
                .privacySensitive()
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 6) {
            Image(systemName: "waveform.path.ecg")
                .font(.system(size: entry.style.homeValueSize(for: family) * 0.65))
                .foregroundStyle(entry.style.themeColor)
                .widgetAccentable()

            Text("\(entry.count)")
                .font(entry.style.homeValueFont(for: family))
                .foregroundStyle(entry.style.themeColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .privacySensitive()

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
                .widgetAccentable()

            VStack(alignment: .leading, spacing: 4) {
                Text("\(entry.count)")
                    .font(entry.style.homeValueFont(for: family))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .privacySensitive()

                Text("heartbeats received from partner")
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
        .description("Heartbeats received from your partner. Tap to open app.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
