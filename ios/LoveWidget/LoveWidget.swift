// ---------------------------------------------------------------------------
// LoveWidget.swift  —  the NATIVE iOS widget (SwiftUI + WidgetKit)
//
// This is the part Flutter CANNOT do. iOS draws this itself.
// Flutter only writes data into the shared App Group; this file reads it.
//
// Paste this into the Widget Extension target you create in Xcode.
// ---------------------------------------------------------------------------

import WidgetKit
import SwiftUI

// MUST match kAppGroupId in lib/widget_demo_main.dart
let appGroupId = "group.com.lovelynk.app.widgetdemo"

// MUST match the keys used in Dart
let countKey = "love_count"
let messageKey = "love_message"

// ── 1. The data model for one snapshot of the widget ────────────────────────
struct LoveEntry: TimelineEntry {
    let date: Date
    let count: Int
    let message: String
}

// ── 2. The Provider: tells iOS WHAT to show and WHEN to refresh ─────────────
struct Provider: TimelineProvider {
    // Reads the values Flutter saved into the shared App Group.
    private func readEntry() -> LoveEntry {
        let defaults = UserDefaults(suiteName: appGroupId)
        let count = defaults?.integer(forKey: countKey) ?? 0
        let message = defaults?.string(forKey: messageKey) ?? "Tap ❤️"
        return LoveEntry(date: Date(), count: count, message: message)
    }

    // Shown while the widget is loading / in the gallery preview.
    func placeholder(in context: Context) -> LoveEntry {
        LoveEntry(date: Date(), count: 3, message: "Thinking of you ×3")
    }

    // A single snapshot (used by the widget gallery).
    func getSnapshot(in context: Context, completion: @escaping (LoveEntry) -> Void) {
        completion(readEntry())
    }

    // The TIMELINE: here we just give one entry and ask iOS to refresh
    // whenever Flutter calls updateWidget (.never = no auto schedule).
    func getTimeline(in context: Context, completion: @escaping (Timeline<LoveEntry>) -> Void) {
        let timeline = Timeline(entries: [readEntry()], policy: .never)
        completion(timeline)
    }
}

// ── 3. The SwiftUI view — one layout per widget "family" (size) ─────────────
struct LoveWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        // Lock-screen: a small circular badge
        case .accessoryCircular:
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    Text("❤️").font(.caption2)
                    Text("\(entry.count)").font(.headline)
                }
            }
        // Lock-screen: a wide one-liner
        case .accessoryRectangular:
            HStack {
                Text("❤️")
                Text(entry.message).font(.headline)
            }
        // Lock-screen: inline text next to the clock
        case .accessoryInline:
            Text("❤️ \(entry.count)")
        // Home-screen sizes
        default:
            VStack(spacing: 8) {
                Text("❤️").font(.system(size: 40))
                Text("\(entry.count)")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundColor(.pink)
                Text(entry.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}

// ── 4. The Widget definition (its "kind" MUST match kIOSWidgetName in Dart) ─
struct LoveWidget: Widget {
    let kind: String = "LoveWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                LoveWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                LoveWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Love Counter")
        .description("Shows how many taps your partner sent.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,     // lock screen
            .accessoryRectangular,  // lock screen
            .accessoryInline,       // lock screen
        ])
    }
}

// ── 5. The bundle that groups all your widgets together ─────────────────────
@main
struct LoveWidgetBundle: WidgetBundle {
    var body: some Widget {
        LoveWidget()
    }
}
