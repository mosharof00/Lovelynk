import WidgetKit
import SwiftUI

// MARK: - Entry

struct InitialsEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let lockMessage: String
    let userInitial: String
    let partnerInitial: String
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct InitialsProvider: TimelineProvider {
    func placeholder(in context: Context) -> InitialsEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (InitialsEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<InitialsEntry>) -> Void) {
        let entry = readEntry()
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }

    private func readEntry() -> InitialsEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
        )
        let user = AppGroupStore.string(WidgetKeys.Initials.userInitial, default: "J")
        let partner = AppGroupStore.string(WidgetKeys.Initials.partnerInitial, default: "M")
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.Initials.widgetId)
        return InitialsEntry(
            date: Date(),
            isLocked: locked,
            lockMessage: lockMessage,
            userInitial: user.isEmpty ? "?" : user,
            partnerInitial: partner.isEmpty ? "?" : partner,
            style: style
        )
    }

    private func sampleEntry() -> InitialsEntry {
        InitialsEntry(
            date: Date(),
            isLocked: false,
            lockMessage: "Locked",
            userInitial: "J",
            partnerInitial: "M",
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.Initials.widgetId)
        )
    }
}

// MARK: - Views

struct InitialsWidgetView: View {
    var entry: InitialsEntry
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
            accessoryCircularLayout
        case .accessoryRectangular:
            accessoryRectangularLayout
        case .accessoryInline:
            Text("\(entry.userInitial) ♥ \(entry.partnerInitial)")
                .font(.headline)
        case .systemMedium:
            homeLayout
        default:
            homeLayout
        }
    }

    /// Fills the lock-screen circular slot with large initials.
    private var accessoryCircularLayout: some View {
        HStack(spacing: 2) {
            Text(entry.userInitial)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Image(systemName: "heart.fill")
                .font(.system(size: 11, weight: .bold))
            Text(entry.partnerInitial)
                .font(.system(size: 22, weight: .bold, design: .rounded))
        }
        .minimumScaleFactor(0.6)
        .lineLimit(1)
    }

    /// Large initials for lock-screen rectangular slot.
    private var accessoryRectangularLayout: some View {
        HStack(spacing: 10) {
            Text(entry.userInitial)
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Image(systemName: "heart.fill")
                .font(.system(size: 18, weight: .bold))
            Text(entry.partnerInitial)
                .font(.system(size: 34, weight: .bold, design: .rounded))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }

    private var homeLayout: some View {
        let diameter = entry.style.initialsCircleDiameter(for: family)
        let heartSize = diameter * 0.42
        let spacing = family == .systemMedium ? 14.0 : 10.0

        return HStack(spacing: spacing) {
            initialCircle(entry.userInitial, diameter: diameter)
            LoveDoubleIcon(size: heartSize, color: entry.style.themeColor)
            initialCircle(entry.partnerInitial, diameter: diameter)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private func initialCircle(_ initial: String, diameter: CGFloat) -> some View {
        Text(initial)
            .font(.system(size: diameter * 0.38, weight: .bold, design: .rounded))
            .foregroundStyle(entry.style.themeColor)
            .frame(width: diameter, height: diameter)
            .overlay(
                Circle()
                    .stroke(entry.style.themeColor, lineWidth: 2)
            )
    }
}

// MARK: - Widget definition

struct InitialsWidget: Widget {
    let kind: String = "InitialsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: InitialsProvider()) { entry in
            InitialsWidgetView(entry: entry)
        }
        .configurationDisplayName("Initials")
        .description("Your and your partner's initials.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
