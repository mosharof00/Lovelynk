import WidgetKit
import SwiftUI

// MARK: - Entry

struct NextVisitEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    /// Visit target — OS timer counts down to this date every second.
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
        let entry = readEntry(at: Date())
        // Rare reload — live seconds come from Text(_:style: .timer).
        var refresh = Calendar.current.date(byAdding: .hour, value: 6, to: Date())
            ?? Date().addingTimeInterval(21_600)
        if let target = entry.target, target > Date(), target < refresh {
            refresh = target
        }
        completion(Timeline(entries: [entry], policy: .after(refresh)))
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
            WidgetLiveTimer.countDown(
                to: entry.target,
                font: .system(size: 12, weight: .bold, design: .rounded)
            )
            .minimumScaleFactor(0.4)
        case .accessoryRectangular:
            HStack(spacing: 6) {
                Image(systemName: "airplane")
                WidgetLiveTimer.countDown(
                    to: entry.target,
                    font: .headline
                )
            }
        case .accessoryInline:
            HStack(spacing: 4) {
                Text("✈️")
                WidgetLiveTimer.countDown(
                    to: entry.target,
                    font: .body.weight(.semibold)
                )
            }
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

            WidgetLiveTimer.countDown(
                to: entry.target,
                font: .system(
                    size: entry.style.homeValueSize(for: family) * 0.42,
                    weight: .bold,
                    design: .rounded
                ),
                color: entry.style.themeColor
            )
            .frame(maxWidth: .infinity)

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

            WidgetLiveTimer.countDown(
                to: entry.target,
                font: .system(
                    size: entry.style.homeValueSize(for: family) * 0.55,
                    weight: .bold,
                    design: .rounded
                ),
                color: entry.style.themeColor
            )
            .frame(maxWidth: .infinity)

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
