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
                Text(entry.userInitial)
                    .font(.headline)
            }
        case .accessoryRectangular:
            initialsRow(fontSize: 14)
        case .accessoryInline:
            Text("\(entry.userInitial) ♥ \(entry.partnerInitial)")
        default:
            VStack(spacing: 8) {
                initialsRow(fontSize: entry.style.valueSize * 0.55)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .widgetBackground(entry.style)
        }
    }

    private func initialsRow(fontSize: CGFloat) -> some View {
        HStack(spacing: 6) {
            Text(entry.userInitial)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(entry.style.themeColor)
            Text("♥")
                .font(.system(size: fontSize * 0.85))
                .foregroundStyle(entry.style.themeColor.opacity(0.85))
            Text(entry.partnerInitial)
                .font(.system(size: fontSize, weight: .bold, design: .rounded))
                .foregroundStyle(entry.style.themeColor)
        }
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
