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
            VStack(spacing: 0) {
                LoveDoubleIcon(size: 16, color: .primary)
                Text("\(entry.miles)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
            }
        case .accessoryRectangular:
            accessoryRectangularLayout
        case .accessoryInline:
            Text("\(entry.miles) mi apart")
        case .systemMedium:
            competitorLayout(circleSize: 36, heartSize: 28, titleSize: entry.style.homeTitleSize(for: family) + 2)
        default:
            competitorLayout(circleSize: 30, heartSize: 24, titleSize: entry.style.homeTitleSize(for: family))
        }
    }

    /// Lock rectangular: compact competitor-style track.
    private var accessoryRectangularLayout: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Our distance: \(entry.miles) mi")
                .font(.system(size: 12, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            distanceConnectionRow(circleSize: 22, heartSize: 16, lineColor: .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    /// Home screen layout matching competitor: title + initials connected by double heart.
    private func competitorLayout(
        circleSize: CGFloat,
        heartSize: CGFloat,
        titleSize: CGFloat
    ) -> some View {
        VStack(spacing: 0) {
            Text("Our distance: \(entry.miles) miles")
                .font(.system(size: titleSize, weight: .semibold))
                .foregroundStyle(entry.style.themeColor)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(maxWidth: .infinity)

            Spacer(minLength: 8)

            distanceConnectionRow(
                circleSize: circleSize,
                heartSize: heartSize,
                lineColor: entry.style.themeColor
            )

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private func distanceConnectionRow(
        circleSize: CGFloat,
        heartSize: CGFloat,
        lineColor: Color
    ) -> some View {
        HStack(spacing: 0) {
            initialCircle(entry.userInitial, size: circleSize, color: lineColor)

            connectionLine(color: lineColor)

            LoveDoubleIcon(size: heartSize, color: lineColor)
                .padding(.horizontal, 4)

            connectionLine(color: lineColor)

            initialCircle(entry.partnerInitial, size: circleSize, color: lineColor)
        }
        .frame(maxWidth: .infinity)
    }

    private func connectionLine(color: Color) -> some View {
        Rectangle()
            .fill(color.opacity(0.55))
            .frame(height: 1.5)
            .frame(maxWidth: .infinity)
    }

    private func initialCircle(_ initial: String, size: CGFloat, color: Color) -> some View {
        Text(initial)
            .font(.system(size: size * 0.42, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(color.opacity(0.12))
            )
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 1.5)
            )
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
