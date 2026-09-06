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
            default: "12 April 2025"
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
            dateLabel: "12 April 2025",
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
            // Compact vertical: day / month
            VStack(spacing: 0) {
                Text(dateDay)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text(dateMonthShort.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        case .accessoryRectangular:
            // Lock long horizontal: "12 Oct" / "2025"
            VStack(alignment: .leading, spacing: 2) {
                Text("Anniversary")
                    .font(.system(size: 11, weight: .medium))
                Text("\(dateDay) \(dateMonthShort)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text(dateYear)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                Text("\(entry.daysToGo) days to go")
                    .font(.system(size: 11, weight: .regular))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        case .accessoryInline:
            Text("💍 \(dateDay) \(dateMonthShort) \(dateYear)")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    /// Parses "12 April 2025" (or similar) into day / month / year.
    private var dateParts: [String] {
        entry.dateLabel.split(separator: " ").map(String.init)
    }

    private var dateDay: String {
        dateParts.first ?? entry.dateLabel
    }

    private var dateMonthFull: String {
        dateParts.count >= 2 ? dateParts[1] : ""
    }

    private var dateMonthShort: String {
        String(dateMonthFull.prefix(3))
    }

    private var dateYear: String {
        dateParts.count >= 3 ? dateParts[2] : ""
    }

    /// Home small / default: vertical day / month / year.
    private var smallLayout: some View {
        VStack(spacing: 0) {
            Text("Anniversary")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            VStack(spacing: 2) {
                Text(dateDay)
                    .font(.system(
                        size: entry.style.homeValueSize(for: family) * 0.55,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundStyle(entry.style.themeColor)
                Text(dateMonthShort)
                    .font(.system(
                        size: entry.style.homeValueSize(for: family) * 0.42,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundStyle(entry.style.themeColor)
                Text(dateYear)
                    .font(.system(
                        size: entry.style.homeValueSize(for: family) * 0.42,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundStyle(entry.style.themeColor)

                Text("\(entry.daysToGo) days to go")
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .regular))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(.top, 4)
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    /// Home medium (long horizontal): "12 Oct" / "2025".
    private var mediumLayout: some View {
        VStack(spacing: 0) {
            Text("Anniversary")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                Text("\(dateDay) \(dateMonthShort)")
                    .font(entry.style.homeValueFont(for: family))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.55)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)

                Text(dateYear)
                    .font(.system(
                        size: entry.style.homeValueSize(for: family) * 0.72,
                        weight: .bold,
                        design: .rounded
                    ))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.55)
                    .lineLimit(1)

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
