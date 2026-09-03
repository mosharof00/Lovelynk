import WidgetKit
import SwiftUI

// MARK: - Entry

struct PartnerWeatherEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    let temperature: Int
    let condition: String
    let city: String
    let iconKey: String
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct PartnerWeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> PartnerWeatherEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (PartnerWeatherEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PartnerWeatherEntry>) -> Void) {
        let entry = readEntry()
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func readEntry() -> PartnerWeatherEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let temperature = AppGroupStore.int(WidgetKeys.PartnerWeather.temperature, default: 22)
        let condition = AppGroupStore.string(
            WidgetKeys.PartnerWeather.condition,
            default: "Partly Cloudy"
        )
        let city = AppGroupStore.string(
            WidgetKeys.PartnerWeather.city,
            default: "Sydney, Australia"
        )
        let iconKey = AppGroupStore.string(
            WidgetKeys.PartnerWeather.iconKey,
            default: "partly_cloudy"
        )
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.PartnerWeather.widgetId)

        return PartnerWeatherEntry(
            date: Date(),
            isLocked: locked,
            lockMessage: lockMessage,
            temperature: temperature,
            condition: condition,
            city: city,
            iconKey: iconKey,
            style: style
        )
    }

    private func sampleEntry() -> PartnerWeatherEntry {
        PartnerWeatherEntry(
            date: Date(),
            isLocked: false,
            lockMessage: "Locked",
            temperature: 22,
            condition: "Partly Cloudy",
            city: "Sydney, Australia",
            iconKey: "partly_cloudy",
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.PartnerWeather.widgetId)
        )
    }
}

// MARK: - Views

struct PartnerWeatherWidgetView: View {
    var entry: PartnerWeatherEntry
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
            Text("\(entry.temperature)°")
                    .font(.headline)
        case .accessoryRectangular:
            HStack {
                Text(WidgetWeatherIcon.emoji(for: entry.iconKey))
                Text("\(entry.temperature)° \(entry.condition)").font(.headline)
            }
        case .accessoryInline:
            Text("\(WidgetWeatherIcon.emoji(for: entry.iconKey)) \(entry.temperature)° \(entry.city)")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 0) {
            Text("Partner Weather")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 0)

            HStack(alignment: .center, spacing: 8) {
                Image(systemName: WidgetWeatherIcon.systemName(for: entry.iconKey))
                    .font(.system(size: entry.style.homeValueSize(for: family) * 0.55))
                    .foregroundStyle(entry.style.themeColor)

                Text("\(entry.temperature)°")
                    .font(entry.style.homeValueFont(for: family))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)

            Text(entry.condition)
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .semibold))
                .foregroundStyle(entry.style.themeColor)
                .lineLimit(1)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 4)

            cityRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Partner Weather")
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)

                Spacer(minLength: 0)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(entry.temperature)°")
                        .font(entry.style.homeValueFont(for: family))
                        .foregroundStyle(entry.style.themeColor)
                    Text(entry.condition)
                        .font(.system(
                            size: entry.style.homeTitleSize(for: family) + 2,
                            weight: .medium
                        ))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                cityRow
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Spacer(minLength: 0)

            Image(systemName: WidgetWeatherIcon.systemName(for: entry.iconKey))
                .font(.system(size: entry.style.homeValueSize(for: family) * 0.72))
                .foregroundStyle(entry.style.themeColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var cityRow: some View {
        HStack(spacing: 3) {
            Image(systemName: "location.fill")
                .font(.system(size: entry.style.homeTitleSize(for: family) - 1))
            Text(entry.city)
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .regular))
                .lineLimit(1)
        }
        .foregroundStyle(.secondary)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Widget definition

struct PartnerWeatherWidget: Widget {
    let kind: String = "PartnerWeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PartnerWeatherProvider()) { entry in
            PartnerWeatherWidgetView(entry: entry)
        }
        .configurationDisplayName("Partner Weather")
        .description("Weather where your partner is.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
