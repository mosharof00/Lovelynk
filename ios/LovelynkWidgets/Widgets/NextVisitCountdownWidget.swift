import WidgetKit
import SwiftUI

// MARK: - Entry

struct NextVisitEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
    let lockMessage: String
    let target: Date?
    let days: Int
    let hours: Int
    let minutes: Int
    let seconds: Int
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
        let now = Date()
        var entries: [NextVisitEntry] = []
        for secondOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: now)!
            entries.append(readEntry(at: entryDate))
        }
        let timeline = Timeline(entries: entries, policy: .atEnd)
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
        let parts: (days: Int, hours: Int, minutes: Int, seconds: Int)
        if let target, target > date {
            parts = WidgetTimeMath.durationComponents(from: date, to: target)
        } else {
            parts = (0, 0, 0, 0)
        }
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.NextVisit.widgetId)

        return NextVisitEntry(
            date: date,
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            target: target,
            days: parts.days,
            hours: parts.hours,
            minutes: parts.minutes,
            seconds: parts.seconds,
            style: style
        )
    }

    private func sampleEntry(at date: Date) -> NextVisitEntry {
        let target = Calendar.current.date(byAdding: .day, value: 76, to: date) ?? date
        let parts = WidgetTimeMath.durationComponents(from: date, to: target)
        return NextVisitEntry(
            date: date,
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            target: target,
            days: parts.days,
            hours: parts.hours,
            minutes: parts.minutes,
            seconds: parts.seconds,
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

    private var counterLine: String {
        String(
            format: "%02d:%02d:%02d:%02d",
            entry.days,
            entry.hours,
            entry.minutes,
            entry.seconds
        )
    }

    @ViewBuilder
    private var contentView: some View {
        switch family {
        case .accessoryCircular:
            WidgetCountdownLayout.accessoryCircular(
                days: entry.days,
                hours: entry.hours,
                minutes: entry.minutes,
                seconds: entry.seconds,
                title: "Visit"
            )
        case .accessoryRectangular:
            WidgetCountdownLayout.accessoryRectangular(
                days: entry.days,
                hours: entry.hours,
                minutes: entry.minutes,
                seconds: entry.seconds,
                title: "Next Visit"
            )
        case .accessoryInline:
            Text("✈️ \(counterLine)")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 0) {
            Text("Next Visit")
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
            Text("Next Visit")
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

struct NextVisitCountdownWidget: Widget {
    let kind: String = "NextVisitCountdownWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NextVisitProvider()) { entry in
            NextVisitCountdownWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Visit Countdown")
        .description("Countdown to your next visit together.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
