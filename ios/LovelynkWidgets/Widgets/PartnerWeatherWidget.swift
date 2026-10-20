import WidgetKit
import SwiftUI

// MARK: - Entry

struct PartnerWeatherEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
    let lockMessage: String
    let hasWeather: Bool
    let temperature: Int
    let condition: String
    let city: String
    let iconKey: String
    let updatedAt: Date?
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
        // Phase 8: Timeline reload policy 30-60 min
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func readEntry() -> PartnerWeatherEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )

        let rawTemp = AppGroupStore.string(WidgetKeys.PartnerWeather.temperature)
        let hasWeather = !rawTemp.isEmpty
        let temperature = Int(rawTemp) ?? 0

        // Neutral fallbacks: remove mock "22° Partly Cloudy" and "Sydney"
        let condition = AppGroupStore.string(
            WidgetKeys.PartnerWeather.condition,
            default: isPaired ? "Weather unknown" : "—"
        )
        let city = AppGroupStore.string(
            WidgetKeys.PartnerWeather.city,
            default: isPaired ? "Partner's City" : "—"
        )
        let iconKey = AppGroupStore.string(
            WidgetKeys.PartnerWeather.iconKey,
            default: "partly_cloudy"
        )
        let updatedAt = AppGroupStore.isoDate(WidgetKeys.PartnerWeather.updatedAt)
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.PartnerWeather.widgetId)

        return PartnerWeatherEntry(
            date: Date(),
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            hasWeather: hasWeather,
            temperature: temperature,
            condition: condition,
            city: city,
            iconKey: iconKey,
            updatedAt: updatedAt,
            style: style
        )
    }

    private func sampleEntry() -> PartnerWeatherEntry {
        PartnerWeatherEntry(
            date: Date(),
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            hasWeather: true,
            temperature: 22,
            condition: "Partly Cloudy",
            city: "Partner's City",
            iconKey: "partly_cloudy",
            updatedAt: Date(),
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
            } else if !entry.isPaired {
                unpairedView
            } else if !entry.hasWeather {
                emptyWeatherView
            } else {
                contentView
            }
        }
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.PartnerWeather.widgetId))
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
    private var emptyWeatherView: some View {
        switch family {
        case .accessoryCircular:
            VStack(spacing: 0) {
                Image(systemName: "cloud.sun")
                    .font(.caption)
                Text("Weather").font(.caption2)
            }
        case .accessoryRectangular:
            HStack {
                Image(systemName: "cloud.sun")
                Text("Partner weather").font(.headline).lineLimit(1)
            }
        case .accessoryInline:
            Text("⛅ Partner weather unavailable")
        default:
            VStack(spacing: 8) {
                Image(systemName: "cloud.sun")
                    .font(.title)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
                Text("Partner Weather")
                    .font(.headline)
                Text("Open app to update")
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
                WidgetWeatherIconView(iconKey: entry.iconKey, size: 14)
                    .widgetAccentable()
                Text("\(entry.temperature)°")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .privacySensitive()
            }
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    WidgetWeatherIconView(iconKey: entry.iconKey, size: 14)
                        .widgetAccentable()
                    Text(entry.city)
                        .font(.system(size: 11, weight: .medium))
                        .lineLimit(1)
                        .privacySensitive()
                }
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(entry.temperature)°")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .privacySensitive()
                    Text(entry.condition)
                        .font(.system(size: 11, weight: .regular))
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        case .accessoryInline:
            Text("⛅ \(entry.city): \(entry.temperature)° \(entry.condition)")
                .privacySensitive()
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.city)
                        .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .privacySensitive()

                    Text(entry.condition)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 4)

                WidgetWeatherIconView(iconKey: entry.iconKey, size: 28)
                    .foregroundStyle(entry.style.themeColor)
                    .widgetAccentable()
            }

            Spacer(minLength: 4)

            Text("\(entry.temperature)°")
                .font(entry.style.homeValueFont(for: family))
                .foregroundStyle(entry.style.themeColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
                .privacySensitive()

            Spacer(minLength: 4)

            if let updated = entry.updatedAt {
                HStack(spacing: 3) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                    Text(updated, style: .relative)
                        .font(.system(size: 10))
                    Text("ago")
                        .font(.system(size: 10))
                }
                .foregroundStyle(.secondary)
                .privacySensitive()
            } else {
                Text("Partner's forecast")
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
                Text(entry.city)
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .privacySensitive()

                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text("\(entry.temperature)°")
                        .font(entry.style.homeValueFont(for: family))
                        .foregroundStyle(entry.style.themeColor)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                        .privacySensitive()

                    Text(entry.condition)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let updated = entry.updatedAt {
                    HStack(spacing: 3) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                        Text("Updated")
                            .font(.system(size: 11))
                        Text(updated, style: .relative)
                            .font(.system(size: 11))
                        Text("ago")
                            .font(.system(size: 11))
                    }
                    .foregroundStyle(.secondary)
                    .privacySensitive()
                }
            }

            Spacer(minLength: 0)

            WidgetWeatherIconView(iconKey: entry.iconKey, size: 48)
                .foregroundStyle(entry.style.themeColor)
                .widgetAccentable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
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
        .description("Current weather and temperature where your partner is.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
