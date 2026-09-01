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

    /// Miles at which initials sit at opposite edges (fully apart).
    private let maxMiles: Double = 500

    var body: some View {
        Group {
            if entry.isLocked {
                lockedView
            } else {
                contentView
            }
        }
        .accessoryWidgetContainer(family: family)
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
            Text("\(entry.miles)")
                    .font(.headline)
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

    /// 0 = far apart (edges), 1 = together (next to heart).
    private var proximity: CGFloat {
        CGFloat(max(0, min(1, 1 - (Double(entry.miles) / maxMiles))))
    }

    private var smallLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Our distance")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)

            Spacer(minLength: 2)

            Text("\(entry.miles)")
                .font(entry.style.homeValueFont(for: family))
                .foregroundStyle(entry.style.themeColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Text("miles")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .regular))
                .foregroundStyle(.secondary)

            Spacer(minLength: 8)

            distanceTrack(circleSize: 26)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(WidgetLayoutMetrics.homePadding)
        .widgetBackground(entry.style)
    }

    private var mediumLayout: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Our distance")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)

            Spacer(minLength: 2)

            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("\(entry.miles)")
                    .font(entry.style.homeValueFont(for: family))
                    .foregroundStyle(entry.style.themeColor)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                Text("miles")
                    .font(.system(
                        size: entry.style.homeTitleSize(for: family) + 4,
                        weight: .medium
                    ))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 8)

            distanceTrack(circleSize: 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(WidgetLayoutMetrics.homePadding)
        .widgetBackground(entry.style)
    }

    /// J ── ♥ ── M track. Heart stays centered; initials slide toward/away with [proximity].
    private func distanceTrack(circleSize: CGFloat) -> some View {
        let heartSize = circleSize * 0.5
        let trackHeight = circleSize + 4

        return GeometryReader { geo in
            let width = geo.size.width
            let centerX = width / 2
            let halfCircle = circleSize / 2

            // Closest each initial can sit next to the heart (centers).
            let nearCenterX = centerX - heartSize / 2 - 6 - halfCircle
            // Farthest: flush to left/right edges.
            let farEdgeX = halfCircle

            let userX = farEdgeX + (nearCenterX - farEdgeX) * proximity
            let partnerX = width - userX

            ZStack {
                // Soft dots between initials and heart
                DistanceDotsShape(
                    leftStart: userX + halfCircle + 4,
                    leftEnd: centerX - heartSize / 2 - 4,
                    rightStart: centerX + heartSize / 2 + 4,
                    rightEnd: partnerX - halfCircle - 4,
                    y: trackHeight / 2
                )
                .stroke(entry.style.themeColor.opacity(0.35), style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [2, 5]))

                Image(systemName: "heart.fill")
                    .font(.system(size: heartSize))
                    .foregroundStyle(entry.style.themeColor)
                    .position(x: centerX, y: trackHeight / 2)

                initialCircle(entry.userInitial, size: circleSize)
                    .position(x: userX, y: trackHeight / 2)

                initialCircle(entry.partnerInitial, size: circleSize)
                    .position(x: partnerX, y: trackHeight / 2)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: trackHeight)
    }

    private func initialCircle(_ initial: String, size: CGFloat) -> some View {
        Text(initial)
            .font(.system(size: size * 0.38, weight: .bold, design: .rounded))
            .foregroundStyle(entry.style.themeColor)
            .frame(width: size, height: size)
            .overlay(
                Circle()
                    .stroke(entry.style.themeColor, lineWidth: 1.5)
            )
    }
}

/// Decorative dashed path between the two gaps (user↔heart, heart↔partner).
private struct DistanceDotsShape: Shape {
    var leftStart: CGFloat
    var leftEnd: CGFloat
    var rightStart: CGFloat
    var rightEnd: CGFloat
    var y: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        if leftEnd > leftStart + 4 {
            path.move(to: CGPoint(x: leftStart, y: y))
            path.addLine(to: CGPoint(x: leftEnd, y: y))
        }
        if rightEnd > rightStart + 4 {
            path.move(to: CGPoint(x: rightStart, y: y))
            path.addLine(to: CGPoint(x: rightEnd, y: y))
        }
        return path
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
