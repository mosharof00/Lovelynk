import WidgetKit
import SwiftUI

// MARK: - Entry

struct EmojiEntry: TimelineEntry {
    let date: Date
    let isLocked: Bool
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
        completion(Timeline(entries: [entry], policy: .never))
    }

    private func readEntry() -> EmojiEntry {
        let locked = AppGroupStore.bool(WidgetKeys.globalLocked)
        let lockMessage = AppGroupStore.string(
            WidgetKeys.globalLockMessage,
            default: "Locked"
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
            lockMessage: lockMessage,
            recentEmojis: Array(emojis.prefix(3)),
            style: style
        )
    }

    private func sampleEntry() -> EmojiEntry {
        EmojiEntry(
            date: Date(),
            isLocked: false,
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
            } else {
                contentView
            }
        }
        .accessoryWidgetContainer(family: family)
        .widgetURL(WidgetDeepLinks.emoji)
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
            Text(entry.recentEmojis.first ?? "😊").font(.title3)
        case .accessoryRectangular:
            HStack(spacing: 4) {
                ForEach(entry.recentEmojis, id: \.self) { emoji in
                    Text(emoji)
                }
                if entry.recentEmojis.isEmpty {
                    Text("😊")
                }
            }
            .font(.headline)
        case .accessoryInline:
            Text("\(entry.recentEmojis.joined(separator: " ")) from partner")
        case .systemMedium:
            mediumLayout
        default:
            smallLayout
        }
    }

    private var emojiRowFontSize: CGFloat {
        switch family {
        case .systemSmall:
            return entry.style.homeValueSize(for: family) * 0.42
        default:
            return entry.style.homeValueSize(for: family) * 0.38
        }
    }

    private var smallLayout: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                ForEach(entry.recentEmojis, id: \.self) { emoji in
                    Text(emoji)
                        .font(.system(size: emojiRowFontSize))
                }
                if entry.recentEmojis.isEmpty {
                    Text("😊")
                        .font(.system(size: emojiRowFontSize))
                }
            }
            Text("from partner")
                .font(.system(size: entry.style.homeTitleSize(for: family)))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
        .widgetBackground(entry.style)
    }

    private var mediumLayout: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                ForEach(entry.recentEmojis, id: \.self) { emoji in
                    Text(emoji)
                        .font(.system(size: entry.style.homeValueSize(for: family) * 0.55))
                }
                if entry.recentEmojis.isEmpty {
                    Text("😊")
                        .font(.system(size: entry.style.homeValueSize(for: family) * 0.55))
                }
            }
            Text("recent from partner")
                .font(.system(size: entry.style.homeTitleSize(for: family)))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(WidgetLayoutMetrics.homePadding)
        .widgetBackground(entry.style)
    }
}

// MARK: - Widget definition

struct EmojiWidget: Widget {
    let kind: String = "EmojiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EmojiProvider()) { entry in
            EmojiWidgetView(entry: entry)
        }
        .configurationDisplayName("Emoji")
        .description("Recent emojis from your partner. Tap to send one back.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}
