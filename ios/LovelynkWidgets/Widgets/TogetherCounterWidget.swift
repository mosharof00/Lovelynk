import WidgetKit
import SwiftUI

// MARK: - Entry

struct TogetherCounterEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
    let lockMessage: String
    let hasDate: Bool
    let since: Date
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct TogetherCounterProvider: TimelineProvider {
    func placeholder(in context: Context) -> TogetherCounterEntry {
        sampleEntry(at: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (TogetherCounterEntry) -> Void) {
        completion(readEntry(at: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TogetherCounterEntry>) -> Void) {
        // Phase 8: Battery & timeline quota optimization:
        // Use a single entry with Text(since, style: .timer). SpringBoard renders the live ticking seconds
        // with 0 CPU overhead, eliminating the 60 entries per minute timeline burnout.
        let entry = readEntry(at: Date())
        let nextHour = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextHour))
        completion(timeline)
    }

    private func readEntry(at date: Date) -> TogetherCounterEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )

        let parsedSince = AppGroupStore.isoDate(WidgetKeys.TogetherCounter.since)
            ?? AppGroupStore.isoDate(WidgetKeys.DaysTogether.since)
        let hasDate = parsedSince != nil
        let since = parsedSince ?? date
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.TogetherCounter.widgetId)

        return TogetherCounterEntry(
            date: date,
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            hasDate: hasDate,
            since: since,
            style: style
        )
    }

    private func sampleEntry(at date: Date) -> TogetherCounterEntry {
        let since = Calendar.current.date(byAdding: .day, value: -76, to: date) ?? date
        return TogetherCounterEntry(
            date: date,
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            hasDate: true,
            since: since,
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.TogetherCounter.widgetId)
        )
    }
}

// MARK: - Views

struct TogetherCounterWidgetView: View {
    var entry: TogetherCounterEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            if entry.isLocked {
                lockedView
            } else if !entry.isPaired {
                unpairedView
            } else if !entry.hasDate {
                emptyDateView
            } else {
                contentView
            }
        }
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.TogetherCounter.widgetId))
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
                Image(systemName: "calendar.badge.plus")
                    .font(.caption)
                Text("Start").font(.caption2)
            }
        case .accessoryRectangular:
            HStack {
                Image(systemName: "calendar.badge.plus")
                Text("Set relationship start").font(.headline).lineLimit(1)
            }
        case .accessoryInline:
            Text("♥ Set relationship start date")
        default:
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text("Together Since")
                    .font(.headline)
                Text("Tap to set date in app")
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
                Image(systemName: "heart.fill")
                    .font(.caption2)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                WidgetLiveTimer.countUp(from: entry.since, font: .system(size: 13, weight: .bold, design: .rounded))
                    .privacySensitive()
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("Together For")
                    .font(.system(size: 11, weight: .medium))
                WidgetLiveTimer.countUp(from: entry.since, font: .system(size: 16, weight: .bold, design: .rounded))
                    .privacySensitive()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        case .accessoryInline:
            HStack(spacing: 2) {
                Text("♥ ")
                WidgetLiveTimer.countUp(from: entry.since, font: .body)
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
            Text("Together For")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer(minLength: 4)

            WidgetLiveTimer.countUp(
                from: entry.since,
                font: entry.style.homeValueFont(for: family),
                color: entry.style.themeColor
            )
            .privacySensitive()

            Spacer(minLength: 4)

            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.caption2)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text("Live counter")
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
                Text("Together For")
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                WidgetLiveTimer.countUp(
                    from: entry.since,
                    font: entry.style.homeValueFont(for: family),
                    color: entry.style.themeColor
                )
                .privacySensitive()

                Text("Every second since you fell in love")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundStyle(entry.style.themeColor)
                .widgetAccentable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }
}

// MARK: - Widget definition

struct TogetherCounterWidget: Widget {
    let kind: String = "TogetherCounterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TogetherCounterProvider()) { entry in
            TogetherCounterWidgetView(entry: entry)
        }
        .configurationDisplayName("Together Counter")
        .description("Live timer counting every second you and your partner have been together.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
