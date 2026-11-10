import Flutter
import UIKit
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    if let controller = window?.rootViewController as? FlutterViewController {
      let badgeChannel = FlutterMethodChannel(
        name: "com.lovelynk.app/badge",
        binaryMessenger: controller.binaryMessenger
      )
      badgeChannel.setMethodCallHandler { (call: FlutterMethodCall, callback: @escaping FlutterResult) in
        if call.method == "setBadge" {
          // Keep app icon badge at 0 per user requirement (icon badge disabled)
          AppDelegate.applyBadgeCount(0)
          callback(true)
        } else {
          callback(FlutterMethodNotImplemented)
        }
      }
    }

    AppDelegate.applyBadgeCount(0)

    return result
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    AppDelegate.applyBadgeCount(0)
  }

  static func applyBadgeCount(_ count: Int) {
    let safeCount = max(0, count)
    if #available(iOS 16.0, *) {
      UNUserNotificationCenter.current().setBadgeCount(safeCount, withCompletionHandler: nil)
    }
    UIApplication.shared.applicationIconBadgeNumber = safeCount
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
