import WidgetKit
import SwiftUI

// MARK: - Entry

struct AnniversaryEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    let dateLabel: String
    let daysToGo: Int
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct AnniversaryProvider: TimelineProvider {
    func placeholder(in context: Context) -> AnniversaryEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (AnniversaryEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<AnniversaryEntry>) -> Void) {
        let entry = readEntry()
        let nextMidnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        )
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func readEntry() -> AnniversaryEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let dateLabel = AppGroupStore.string(
            WidgetKeys.Anniversary.dateLabel,
            default: "12 Oct 2025"
        )
        let daysToGo = AppGroupStore.int(WidgetKeys.Anniversary.daysToGo, default: 0)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.Anniversary.widgetId)
        return AnniversaryEntry(
            date: Date(),
            isLocked: locked,
            lockMessage: lockMessage,
            dateLabel: dateLabel,
            daysToGo: daysToGo,
            style: style
        )
    }

    private func sampleEntry() -> AnniversaryEntry {
        AnniversaryEntry(
            date: Date(),
            isLocked: false,
            lockMessage: "Locked",
            dateLabel: "12 Oct 2025",
            daysToGo: 41,
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.Anniversary.widgetId)
        )
    }
}

// MARK: - Views

struct AnniversaryWidgetView: View {
    var entry: AnniversaryEntry
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
            Text("\(entry.daysToGo)")
                    .font(.headline)
        case .accessoryRectangular:
            HStack {
                Text("💍")
                Text("\(entry.daysToGo) days").font(.headline)
            }
        case .accessoryInline:
            Text("💍 \(entry.dateLabel) · \(entry.daysToGo)d")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 0) {
            Text("Anniversary")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                Text(entry.dateLabel)
                    .font(.system(
                        size: entry.style.homeValueSize(for: family) * 0.58,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                Text("\(entry.daysToGo) days to go")
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        VStack(spacing: 0) {
            Text("Anniversary")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            VStack(spacing: 6) {
                Text(entry.dateLabel)
                    .font(entry.style.homeValueFont(for: family))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.55)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                Text("\(entry.daysToGo) days to go")
                    .font(.system(
                        size: entry.style.homeTitleSize(for: family) + 2,
                        weight: .medium
                    ))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
        }
        .overlay(alignment: .topTrailing) {
            Text("💍")
                .font(.system(size: entry.style.homeValueSize(for: family) * 0.55))
                .padding(.top, WidgetLayoutMetrics.homePadding)
                .padding(.trailing, WidgetLayoutMetrics.homePadding)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }
}

// MARK: - Widget definition

struct AnniversaryWidget: Widget {
    let kind: String = "AnniversaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AnniversaryProvider()) { entry in
            AnniversaryWidgetView(entry: entry)
        }
        .configurationDisplayName("Anniversary")
        .description("Count down to your next anniversary.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
