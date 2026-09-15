import WidgetKit
import SwiftUI

// MARK: - Entry

struct NextVisitEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    /// Visit target — remaining D/H/M/S computed against [date].
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
        let now = Date()
        var entries: [NextVisitEntry] = []
        for secondOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .second, value: secondOffset, to: now) ?? now
            entries.append(readEntry(at: entryDate))
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func readEntry(at date: Date) -> NextVisitEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let target = AppGroupStore.isoDate(WidgetKeys.NextVisit.targetAt)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.NextVisit.widgetId)

        return NextVisitEntry(
            date: date,
            isLocked: locked,
            lockMessage: lockMessage,
            target: target,
            style: style
        )
    }

    private func sampleEntry(at date: Date) -> NextVisitEntry {
        let target = Calendar.current.date(byAdding: .day, value: 76, to: date)
        return NextVisitEntry(
            date: date,
            isLocked: false,
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

    private var parts: (days: Int, hours: Int, minutes: Int, seconds: Int) {
        guard let target = entry.target, target > entry.date else {
            return (0, 0, 0, 0)
        }
        return WidgetTimeMath.durationComponents(from: entry.date, to: target)
    }

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
        let p = parts
        switch family {
        case .accessoryCircular:
            WidgetCountdownLayout.accessoryCircular(
                days: p.days,
                hours: p.hours,
                minutes: p.minutes,
                seconds: p.seconds,
                title: "Visit"
            )
        case .accessoryRectangular:
            WidgetCountdownLayout.accessoryRectangular(
                days: p.days,
                hours: p.hours,
                minutes: p.minutes,
                seconds: p.seconds,
                title: "Next visit"
            )
        case .accessoryInline:
            Text("✈️ \(p.days)d \(p.hours)h \(p.minutes)m")
                .font(.body.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.55)
        case .systemMedium:
            mediumLayout(p)
        default:
            smallLayout(p)
        }
    }

    private func smallLayout(
        _ p: (days: Int, hours: Int, minutes: Int, seconds: Int)
    ) -> some View {
        VStack(spacing: 0) {
            Text("Next Visit")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 4)

            WidgetCountdownLayout.smallGrid(
                days: p.days,
                hours: p.hours,
                minutes: p.minutes,
                seconds: p.seconds,
                style: entry.style,
                family: family
            )

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private func mediumLayout(
        _ p: (days: Int, hours: Int, minutes: Int, seconds: Int)
    ) -> some View {
        VStack(spacing: 0) {
            Text("Next Visit")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 4)

            WidgetCountdownLayout.mediumRow(
                days: p.days,
                hours: p.hours,
                minutes: p.minutes,
                seconds: p.seconds,
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
