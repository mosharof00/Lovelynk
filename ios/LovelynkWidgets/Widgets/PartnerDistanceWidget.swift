import WidgetKit
import SwiftUI

// MARK: - Entry

struct PartnerDistanceEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    let miles: Int
    let userInitial: String
    let partnerInitial: String
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct PartnerDistanceProvider: TimelineProvider {
    func placeholder(in context: Context) -> PartnerDistanceEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (PartnerDistanceEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PartnerDistanceEntry>) -> Void) {
        let entry = readEntry()
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func readEntry() -> PartnerDistanceEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let miles = AppGroupStore.int(WidgetKeys.PartnerDistance.miles, default: 0)
        let user = AppGroupStore.string(WidgetKeys.PartnerDistance.userInitial, default: "J")
        let partner = AppGroupStore.string(WidgetKeys.PartnerDistance.partnerInitial, default: "M")
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.PartnerDistance.widgetId)
        return PartnerDistanceEntry(
            date: Date(),
            isLocked: locked,
            lockMessage: lockMessage,
            miles: miles,
            userInitial: user.isEmpty ? "?" : user,
            partnerInitial: partner.isEmpty ? "?" : partner,
            style: style
        )
    }

    private func sampleEntry() -> PartnerDistanceEntry {
        PartnerDistanceEntry(
            date: Date(),
            isLocked: false,
            lockMessage: "Locked",
            miles: 168,
            userInitial: "J",
            partnerInitial: "M",
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.PartnerDistance.widgetId)
        )
    }
}

// MARK: - Views

struct PartnerDistanceWidgetView: View {
    var entry: PartnerDistanceEntry
    @Environment(\.widgetFamily) var family

    private let maxMiles: Double = 500

    var body: some View {
        if entry.isLocked {
            lockedView
        } else {
            contentView
        }
    }

    @ViewBuilder
    private var lockedView: some View {
        switch family {
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "lock.fill")
            }
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
            ZStack {
                AccessoryWidgetBackground()
                Text("\(entry.miles)")
                    .font(.headline)
            }
        case .accessoryRectangular:
            HStack {
                Text("📍")
                Text("\(entry.miles) mi").font(.headline)
            }
        case .accessoryInline:
            Text("📍 \(entry.miles) miles apart")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var proximity: CGFloat {
        let t = max(0, min(1, 1 - (Double(entry.miles) / maxMiles)))
        return CGFloat(t)
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Our distance")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)

            Spacer(minLength: 4)

            Text("\(entry.miles)")
                .font(entry.style.homeValueFont(for: family))
                .foregroundStyle(entry.style.themeColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text("miles")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .regular))
                .foregroundStyle(.secondary)

            Spacer(minLength: 6)

            distanceTrack(height: 28)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(WidgetLayoutMetrics.homePadding)
        .widgetBackground(entry.style)
    }

    private var mediumLayout: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Our distance")
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(entry.miles)")
                        .font(entry.style.homeValueFont(for: family))
                        .foregroundStyle(entry.style.themeColor)
                    Text("miles")
                        .font(.system(
                            size: entry.style.homeTitleSize(for: family) + 4,
                            weight: .medium
                        ))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 4)

                distanceTrack(height: 32)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
        .widgetBackground(entry.style)
    }

    private func distanceTrack(height: CGFloat) -> some View {
        GeometryReader { geo in
            let width = geo.size.width
            let diameter: CGFloat = min(28, height)
            let heartSize: CGFloat = diameter * 0.55
            let centerX = width / 2
            let userMin = centerX - heartSize - 8 - diameter / 2
            let userX = diameter / 2 + (userMin - diameter / 2) * proximity
            let partnerX = width - userX

            ZStack {
                HStack(spacing: 0) {
                    Circle()
                        .stroke(entry.style.themeColor, lineWidth: 1.5)
                        .frame(width: diameter, height: diameter)
                        .overlay(
                            Text(entry.userInitial)
                                .font(.system(size: diameter * 0.38, weight: .bold, design: .rounded))
                                .foregroundStyle(entry.style.themeColor)
                        )
                        .position(x: userX, y: height / 2)

                    Image(systemName: "heart.fill")
                        .font(.system(size: heartSize))
                        .foregroundStyle(entry.style.themeColor)
                        .position(x: centerX, y: height / 2)

                    Circle()
                        .stroke(entry.style.themeColor, lineWidth: 1.5)
                        .frame(width: diameter, height: diameter)
                        .overlay(
                            Text(entry.partnerInitial)
                                .font(.system(size: diameter * 0.38, weight: .bold, design: .rounded))
                                .foregroundStyle(entry.style.themeColor)
                        )
                        .position(x: partnerX, y: height / 2)
                }
            }
        }
        .frame(height: height)
    }
}

// MARK: - Widget definition

struct PartnerDistanceWidget: Widget {
    let kind: String = "PartnerDistanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PartnerDistanceProvider()) { entry in
            PartnerDistanceWidgetView(entry: entry)
        }
        .configurationDisplayName("Partner Distance")
        .description("How far apart you and your partner are.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
