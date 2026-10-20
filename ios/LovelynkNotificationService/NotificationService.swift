//
//  NotificationService.swift
//  LovelynkNotificationService
//
//  Created by M.K on 10/20/26.
//

import UserNotifications
import WidgetKit

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        defer {
            if let bestAttemptContent = bestAttemptContent {
                contentHandler(bestAttemptContent)
            } else {
                contentHandler(request.content)
            }
        }

        // 1. Access the shared App Group
        guard let defaults = UserDefaults(suiteName: "group.com.lovelynk.ios") else {
            return
        }

        let userInfo = request.content.userInfo

        // 2. Extract payload metadata
        // FCM sends keys at the root of userInfo, or inside "widget" or "data" dictionaries
        let widgetDict = userInfo["widget"] as? [String: Any]
        let dataDict = userInfo["data"] as? [String: Any]

        let kind = (userInfo["kind"] as? String)
            ?? (widgetDict?["kind"] as? String)
            ?? (dataDict?["kind"] as? String)
            ?? (userInfo["category"] as? String)
            ?? ""

        let totalStr = (userInfo["total"] as? String)
            ?? (widgetDict?["total"] as? String)
            ?? (dataDict?["total"] as? String)
        let totalVal = totalStr != nil ? Int(totalStr!) : (userInfo["total"] as? Int)

        let countStr = (userInfo["count"] as? String)
            ?? (widgetDict?["count"] as? String)
            ?? (dataDict?["count"] as? String)
        let countToAdd = (countStr != nil ? Int(countStr!) : nil) ?? (userInfo["count"] as? Int) ?? 1

        let emoji = (userInfo["emoji"] as? String)
            ?? (widgetDict?["emoji"] as? String)
            ?? (dataDict?["emoji"] as? String)

        let recentEmojisStr = (userInfo["recent_emojis"] as? String)
            ?? (widgetDict?["recent_emojis"] as? String)
            ?? (dataDict?["recent_emojis"] as? String)

        // 3. Update WidgetKit App Group storage & trigger reload
        switch kind {
        case "heartbeat":
            let finalCount: Int
            if let totalVal = totalVal {
                finalCount = totalVal
            } else {
                let current = Int(defaults.string(forKey: "heartbeat_count") ?? "0") ?? 0
                finalCount = current + countToAdd
            }
            defaults.set("\(finalCount)", forKey: "heartbeat_count")
            defaults.synchronize()
            WidgetCenter.shared.reloadTimelines(ofKind: "HeartbeatWidget")

        case "kiss":
            let finalCount: Int
            if let totalVal = totalVal {
                finalCount = totalVal
            } else {
                let current = Int(defaults.string(forKey: "kiss_count") ?? "0") ?? 0
                finalCount = current + countToAdd
            }
            defaults.set("\(finalCount)", forKey: "kiss_count")
            defaults.synchronize()
            WidgetCenter.shared.reloadTimelines(ofKind: "KissWidget")

        case "emoji":
            if let recentEmojisStr = recentEmojisStr, !recentEmojisStr.isEmpty {
                let top3 = recentEmojisStr.split(separator: ",").prefix(3).joined(separator: ",")
                defaults.set(String(top3), forKey: "emoji_recent")
            } else if let emoji = emoji, !emoji.isEmpty {
                var current = (defaults.string(forKey: "emoji_recent") ?? "")
                    .split(separator: ",")
                    .map(String.init)
                current.removeAll { $0 == emoji }
                current.insert(emoji, at: 0)
                let top3 = current.prefix(3).joined(separator: ",")
                defaults.set(top3, forKey: "emoji_recent")
            }
            defaults.synchronize()
            WidgetCenter.shared.reloadTimelines(ofKind: "EmojiWidget")

        default:
            break
        }

        // Also reload all timelines to ensure Lock Screen accessories refresh immediately
        WidgetCenter.shared.reloadAllTimelines()
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
