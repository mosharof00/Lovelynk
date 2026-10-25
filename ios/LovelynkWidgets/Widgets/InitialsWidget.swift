import WidgetKit
import SwiftUI

// MARK: - Entry

struct InitialsEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
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
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )
        // Phase 8: Remove J/M fallback; show neutral placeholder "—"
        let user = AppGroupStore.string(WidgetKeys.Initials.userInitial, default: "—")
        let partner = AppGroupStore.string(WidgetKeys.Initials.partnerInitial, default: "—")
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.Initials.widgetId)

        return InitialsEntry(
            date: Date(),
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            userInitial: user.isEmpty ? "—" : user,
            partnerInitial: partner.isEmpty ? "—" : partner,
            style: style
        )
    }

    private func sampleEntry() -> InitialsEntry {
        InitialsEntry(
            date: Date(),
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            userInitial: "—",
            partnerInitial: "—",
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
            } else if !entry.isPaired {
                unpairedView
            } else {
                contentView
            }
        }
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.Initials.widgetId))
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
    private var contentView: some View {
        switch family {
        case .accessoryCircular:
            accessoryCircularLayout
        case .accessoryRectangular:
            accessoryRectangularLayout
        case .accessoryInline:
            Text("\(entry.userInitial) ♥ \(entry.partnerInitial)")
                .font(.headline)
                .privacySensitive()
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
                .privacySensitive()
            Image(systemName: "heart.fill")
                .font(.system(size: 11, weight: .bold))
                .widgetAccentable()
            Text(entry.partnerInitial)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .privacySensitive()
        }
        .minimumScaleFactor(0.6)
        .lineLimit(1)
    }

    /// Large initials for lock-screen rectangular slot.
    private var accessoryRectangularLayout: some View {
        HStack(spacing: 10) {
            Text(entry.userInitial)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .privacySensitive()
            Image(systemName: "heart.fill")
                .font(.system(size: 18, weight: .bold))
                .widgetAccentable()
            Text(entry.partnerInitial)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .privacySensitive()
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
            .privacySensitive()
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
