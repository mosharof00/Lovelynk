import WidgetKit
import SwiftUI

// MARK: - Entry

struct NextVisitEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
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
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
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
            lockMessage: lockMessage,
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
            lockMessage: "Locked",
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
            Text("\(entry.days)d")
                    .font(.headline)
        case .accessoryRectangular:
            HStack {
                Image(systemName: "airplane")
                Text(counterLine).font(.headline)
            }
        case .accessoryInline:
            Text("✈️ \(counterLine)")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
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
            Text("Next Visit Countdown")
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
