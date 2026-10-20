import WidgetKit
import SwiftUI

// MARK: - Entry

struct AnniversaryEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
    let lockMessage: String
    let hasDate: Bool
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
            for: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        )
        let timeline = Timeline(entries: [entry], policy: .after(nextMidnight))
        completion(timeline)
    }

    private func readEntry() -> AnniversaryEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )

        // Phase 8: Calculate dynamically in Swift from ISO8601 date
        var hasDate = false
        var dateLabel = "Set a date in LoveLynk"
        var daysToGo = 0

        if let anniversary = AppGroupStore.isoDate(WidgetKeys.Anniversary.date) {
            hasDate = true
            let now = Date()
            let cal = Calendar.current
            let today = cal.startOfDay(for: now)
            let currentYear = cal.component(.year, from: now)
            let month = cal.component(.month, from: anniversary)
            let day = cal.component(.day, from: anniversary)

            var nextComps = DateComponents(year: currentYear, month: month, day: day)
            var nextDate = cal.date(from: nextComps) ?? anniversary
            if nextDate < today {
                nextComps.year = currentYear + 1
                nextDate = cal.date(from: nextComps) ?? anniversary
            }
            let diff = cal.dateComponents([.day], from: today, to: cal.startOfDay(for: nextDate)).day ?? 0
            daysToGo = max(0, diff)

            let formatter = DateFormatter()
            formatter.dateFormat = "d MMMM yyyy"
            dateLabel = formatter.string(from: anniversary)
        } else {
            let label = AppGroupStore.string(WidgetKeys.Anniversary.dateLabel)
            if !label.isEmpty && label != "Set your date in LoveLynk" {
                hasDate = true
                dateLabel = label
                daysToGo = AppGroupStore.int(WidgetKeys.Anniversary.daysToGo, default: 0)
            }
        }

        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.Anniversary.widgetId)

        return AnniversaryEntry(
            date: Date(),
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            hasDate: hasDate,
            dateLabel: dateLabel,
            daysToGo: daysToGo,
            style: style
        )
    }

    private func sampleEntry() -> AnniversaryEntry {
        AnniversaryEntry(
            date: Date(),
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            hasDate: true,
            dateLabel: "14 February 2026",
            daysToGo: 117,
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
            } else if !entry.isPaired {
                unpairedView
            } else if !entry.hasDate {
                emptyDateView
            } else {
                contentView
            }
        }
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.Anniversary.widgetId))
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
                Text("Date").font(.caption2)
            }
        case .accessoryRectangular:
            HStack {
                Image(systemName: "calendar.badge.plus")
                Text("Set anniversary").font(.headline).lineLimit(1)
            }
        case .accessoryInline:
            Text("💍 Set anniversary date")
        default:
            VStack(spacing: 8) {
                Image(systemName: "calendar.badge.plus")
                    .font(.title)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text("Set Anniversary")
                    .font(.headline)
                Text("Tap to pick a date")
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
                Text(dateDay)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                    .privacySensitive()
                Text(dateMonthShort.uppercased())
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text("Anniversary")
                    .font(.system(size: 11, weight: .medium))
                Text("\(dateDay) \(dateMonthShort)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .privacySensitive()
                Text("\(entry.daysToGo) days to go")
                    .font(.system(size: 11, weight: .regular))
                    .lineLimit(1)
                    .privacySensitive()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        case .accessoryInline:
            Text("💍 \(dateDay) \(dateMonthShort) · \(entry.daysToGo)d to go")
                .privacySensitive()
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

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

    private var smallLayout: some View {
        VStack(spacing: 0) {
            Text("Anniversary")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            VStack(spacing: 0) {
                Text(dateDay)
                    .font(.system(size: 38, weight: .bold, design: .rounded))
                    .foregroundStyle(entry.style.themeColor)
                    .lineLimit(1)
                    .privacySensitive()

                Text(dateMonthFull.uppercased())
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(entry.style.themeColor)
                    .lineLimit(1)

                if !dateYear.isEmpty {
                    Text(dateYear)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.secondary)
                        .padding(.top, 1)
                        .privacySensitive()
                }
            }

            Spacer(minLength: 0)

            Text("\(entry.daysToGo) days to go")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .privacySensitive()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Anniversary")
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Text(entry.dateLabel)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(entry.style.themeColor)
                    .lineLimit(1)
                    .privacySensitive()

                Text("\(entry.daysToGo) days until your anniversary")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .privacySensitive()
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

struct AnniversaryWidget: Widget {
    let kind: String = "AnniversaryWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: AnniversaryProvider()) { entry in
            AnniversaryWidgetView(entry: entry)
        }
        .configurationDisplayName("Anniversary")
        .description("Countdown to your next relationship anniversary.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
