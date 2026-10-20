import WidgetKit
import SwiftUI

// MARK: - Entry

struct NextVisitEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
    let lockMessage: String
    let target: Date?
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct NextVisitProvider: TimelineProvider {
    func placeholder(in context: Context) -> NextVisitEntry {
        sampleEntry(at: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (NextVisitEntry) -> Void) {
        completion(readEntry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<NextVisitEntry>) -> Void) {
        // Phase 8: Battery & timeline quota optimization:
        // Use a single entry with Text(target, style: .timer). SpringBoard handles live second updates.
        let entry = readEntry(at: Date())
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let refreshDate: Date
        if let target = entry.target, target > Date(), target < nextHour {
            refreshDate = target
        } else {
            refreshDate = nextHour
        }
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func readEntry(at date: Date) -> NextVisitEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )
        let target = AppGroupStore.isoDate(WidgetKeys.NextVisit.targetAt)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.NextVisit.widgetId)

        return NextVisitEntry(
            date: date,
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            target: target,
            style: style
        )
    }

    private func sampleEntry(at date: Date) -> NextVisitEntry {
        let target = Calendar.current.date(byAdding: .day, value: 14, to: date)
        return NextVisitEntry(
            date: date,
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            target: target,
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.NextVisit.widgetId)
        )
    }
}

// MARK: - Views

struct NextVisitCountdownWidgetView: View {
    var entry: NextVisitEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if entry.isLocked {
                lockedView
            } else if !entry.isPaired {
                unpairedView
            } else if entry.target == nil {
                emptyDateView
            } else {
                contentView
            }
        }
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.NextVisit.widgetId))
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
                Image(systemName: "airplane")
                    .font(.caption)
                Text("Visit").font(.caption2)
            }
        case .accessoryRectangular:
            HStack {
                Image(systemName: "airplane")
                Text("Set next visit").font(.headline).lineLimit(1)
            }
        case .accessoryInline:
            Text("✈️ Set next visit date")
        default:
            VStack(spacing: 8) {
                Image(systemName: "airplane")
                    .font(.title)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text("Next Visit")
                    .font(.headline)
                Text("Tap to set visit date")
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
                Image(systemName: "airplane")
                    .font(.caption2)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                WidgetLiveTimer.countDown(to: entry.target, font: .system(size: 13, weight: .bold, design: .rounded))
                    .privacySensitive()
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("Next Visit In")
                    .font(.system(size: 11, weight: .medium))
                WidgetLiveTimer.countDown(to: entry.target, font: .system(size: 16, weight: .bold, design: .rounded))
                    .privacySensitive()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        case .accessoryInline:
            HStack(spacing: 2) {
                Text("✈️ Next visit: ")
                WidgetLiveTimer.countDown(to: entry.target, font: .body)
            }
            .privacySensitive()
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Next Visit In")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer(minLength: 4)

            WidgetLiveTimer.countDown(
                to: entry.target,
                font: entry.style.homeValueFont(for: family),
                color: entry.style.themeColor
            )
            .privacySensitive()

            Spacer(minLength: 4)

            HStack(spacing: 4) {
                Image(systemName: "airplane")
                    .font(.caption2)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text("Until you reunite")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Next Visit")
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                WidgetLiveTimer.countDown(
                    to: entry.target,
                    font: entry.style.homeValueFont(for: family),
                    color: entry.style.themeColor
                )
                .privacySensitive()

                Text("Countdown until your next trip together")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "airplane")
                .font(.system(size: 40))
                .foregroundStyle(entry.style.themeColor)
                .widgetAccentable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }
}

// MARK: - Widget definition

struct NextVisitCountdownWidget: Widget {
    let kind: String = "NextVisitCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextVisitProvider()) { entry in
            NextVisitCountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Visit")
        .description("Countdown timer until you and your partner see each other next.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
