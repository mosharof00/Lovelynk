// ---------------------------------------------------------------------------
// LOVE COUNTER — Home-screen widget DEMO (learning sandbox)
//
// This file is a STANDALONE learning demo. It does NOT touch your real GetX app.
// Run it with:
//     flutter run -t lib/widget_demo_main.dart
//
// What it teaches:
//   1. Save data into the SHARED App Group so the native widget can read it.
//   2. Ask iOS/WidgetKit to refresh the widget.
//   3. React when the user taps the widget (deep link back into the app).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

// ── Constants shared with the native side ───────────────────────────────────
// IMPORTANT: these strings MUST match what we write in the Swift widget.

// The App Group id. Must be identical in Xcode (Signing & Capabilities) and Swift.
const String kAppGroupId = 'group.com.lovelynk.app.widgetdemo';

// The name of the iOS Widget (the SwiftUI struct / kind). Must match Swift.
const String kIOSWidgetName = 'LoveWidget';

// The keys we store values under. Must match the keys the Swift widget reads.
const String kCountKey = 'love_count';
const String kMessageKey = 'love_message';

void main() {
  runApp(const WidgetDemoApp());
}

class WidgetDemoApp extends StatelessWidget {
  const WidgetDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Widget Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.pink,
        useMaterial3: true,
      ),
      home: const LoveCounterPage(),
    );
  }
}

class LoveCounterPage extends StatefulWidget {
  const LoveCounterPage({super.key});

  @override
  State<LoveCounterPage> createState() => _LoveCounterPageState();
}

class _LoveCounterPageState extends State<LoveCounterPage> {
  int _count = 0;
  String _status = 'Not synced yet';

  @override
  void initState() {
    super.initState();

    // Tell home_widget which App Group to use (iOS only, but harmless elsewhere).
    HomeWidget.setAppGroupId(kAppGroupId);

    // Load whatever value is already stored, so the app + widget agree on startup.
    _loadInitial();

    // Listen for when the user taps the widget (it opens the app via a deep link).
    HomeWidget.widgetClicked.listen(_onWidgetClicked);
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_onWidgetClicked);
  }

  Future<void> _loadInitial() async {
    final stored = await HomeWidget.getWidgetData<int>(kCountKey, defaultValue: 0);
    setState(() => _count = stored ?? 0);
  }

  void _onWidgetClicked(Uri? uri) {
    if (uri == null) return;
    // Example: widget opened the app with a URL like homeWidgetDemo://tapped
    setState(() => _status = 'Opened from widget tap: $uri');
  }

  /// THE CORE LOOP — this is exactly what every real widget will do:
  /// 1) write data to the shared App Group, 2) ask the OS to refresh the widget.
  Future<void> _increment() async {
    setState(() => _count++);

    // 1) Save the values into the shared storage the widget can read.
    await HomeWidget.saveWidgetData<int>(kCountKey, _count);
    await HomeWidget.saveWidgetData<String>(
      kMessageKey,
      _count == 0 ? 'Tap ❤️' : 'Thinking of you ×$_count',
    );

    // 2) Ask WidgetKit to redraw the widget with the new data.
    await HomeWidget.updateWidget(
      iOSName: kIOSWidgetName,
      // androidName / qualifiedAndroidName would go here for Android support.
    );

    setState(() => _status = 'Synced ✓  (widget should now show $_count)');
  }

  Future<void> _reset() async {
    setState(() => _count = 0);
    await HomeWidget.saveWidgetData<int>(kCountKey, 0);
    await HomeWidget.saveWidgetData<String>(kMessageKey, 'Tap ❤️');
    await HomeWidget.updateWidget(iOSName: kIOSWidgetName);
    setState(() => _status = 'Reset ✓');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Love Counter — Widget Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Taps sent to your partner', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '$_count ❤️',
              style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _increment,
              icon: const Icon(Icons.favorite),
              label: const Text('Send a tap ❤️'),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: _reset, child: const Text('Reset')),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
