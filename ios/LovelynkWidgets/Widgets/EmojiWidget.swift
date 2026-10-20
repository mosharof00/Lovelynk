import WidgetKit
import SwiftUI

// MARK: - Entry

struct EmojiEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
    let isPaired: Bool
    let lockMessage: String
    let recentEmojis: [String]
    let style: WidgetStyleConfig
}

// MARK: - Provider

struct EmojiProvider: TimelineProvider {
    func placeholder(in context: Context) -> EmojiEntry {
        sampleEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (EmojiEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<EmojiEntry>) -> Void) {
        let entry = readEntry()
        // Phase 8: Refreshed by push payload or app sync; fallback to after 30 min
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(refreshDate)))
    }

    private func readEntry() -> EmojiEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let isPaired = AppGroupStore.bool(WidgetKeys.isPaired)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: isPaired ? "Locked" : "Connect with your partner"
        )
        let raw = AppGroupStore.string(WidgetKeys.Emoji.recent, default: "")
        let emojis = raw
            .split(separator: ",")
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let style = WidgetStyleConfig.load(widgetId: WidgetKeys.Emoji.widgetId)

        return EmojiEntry(
            date: Date(),
            isLocked: locked,
            isPaired: isPaired,
            lockMessage: lockMessage,
            recentEmojis: Array(emojis.prefix(3)),
            style: style
        )
    }

    private func sampleEntry() -> EmojiEntry {
        EmojiEntry(
            date: Date(),
            isLocked: false,
            isPaired: true,
            lockMessage: "Locked",
            recentEmojis: ["😍", "😘", "🥰"],
            style: WidgetStyleConfig.load(widgetId: WidgetKeys.Emoji.widgetId)
        )
    }
}

// MARK: - Views

struct EmojiWidgetView: View {
    var entry: EmojiEntry
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
        .widgetURL(WidgetDeepLinks.url(for: WidgetKeys.Emoji.widgetId))
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
            if entry.recentEmojis.isEmpty {
                Text("Send an emoji to partner")
            } else {
                Text(entry.recentEmojis.joined(separator: " "))
                    .privacySensitive()
            }
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var accessoryCircularLayout: some View {
        Group {
            if let first = entry.recentEmojis.first {
                Text(first)
                    .font(.system(size: 26))
                    .privacySensitive()
            } else {
                Image(systemName: "face.smiling")
                    .font(.title3)
                    .widgetAccentable()
            }
        }
    }

    private var accessoryRectangularLayout: some View {
        HStack(spacing: 6) {
            if entry.recentEmojis.isEmpty {
                Text("No emojis yet — tap to send")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(Array(entry.recentEmojis.enumerated()), id: \.offset) { _, emoji in
                    Text(emoji)
                        .font(.system(size: 26))
                        .privacySensitive()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private var smallLayout: some View {
        VStack(spacing: 4) {
            Text("Recent Reactions")
                .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer(minLength: 0)

            if entry.recentEmojis.isEmpty {
                VStack(spacing: 4) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 32))
                        .foregroundStyle(entry.style.themeColor)
                        .widgetAccentable()
                    Text("No emojis yet")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack(spacing: 8) {
                    ForEach(Array(entry.recentEmojis.enumerated()), id: \.offset) { _, emoji in
                        Text(emoji)
                            .font(.system(size: entry.style.homeValueSize(for: family) * 0.55))
                            .privacySensitive()
                    }
                }
            }

            Spacer(minLength: 0)

            Text("from partner")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }

    private var mediumLayout: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Recent Reactions")
                    .font(.system(size: entry.style.homeTitleSize(for: family), weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if entry.recentEmojis.isEmpty {
                    Text("No emojis yet from your partner")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    HStack(spacing: 10) {
                        ForEach(Array(entry.recentEmojis.enumerated()), id: \.offset) { _, emoji in
                            Text(emoji)
                                .font(.system(size: entry.style.homeValueSize(for: family) * 0.6))
                                .privacySensitive()
                        }
                    }
                }

                Text("Latest emojis sent by your partner")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "face.smiling")
                .font(.system(size: 40))
                .foregroundStyle(entry.style.themeColor)
                .widgetAccentable()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
    }
}

// MARK: - Widget definition

struct EmojiWidget: Widget {
    let kind: String = "EmojiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EmojiProvider()) { entry in
            EmojiWidgetView(entry: entry)
        }
        .configurationDisplayName("Emoji Reactions")
        .description("Recent emojis from your partner. Tap to open app.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
