import 'package:flutter_test/flutter_test.dart';
import 'package:bulkretail/app/core/widgets/widget_app_group.dart';

void main() {
  test('WidgetAppGroup dataKeys covers all widget keys', () {
    expect(WidgetAppGroup.dataKeys, contains(WidgetAppGroup.isPaired));
    expect(WidgetAppGroup.dataKeys, contains(WidgetAppGroup.partnerName));
    expect(WidgetAppGroup.dataKeys, contains(WidgetAppGroup.daysTogetherSince));
    expect(WidgetAppGroup.dataKeys, contains(WidgetAppGroup.togetherCounterSince));
    expect(WidgetAppGroup.dataKeys, contains(WidgetAppGroup.anniversaryDate));
    expect(WidgetAppGroup.dataKeys, contains(WidgetAppGroup.partnerDistanceUnit));
    expect(WidgetAppGroup.dataKeys, contains(WidgetAppGroup.partnerDistanceIsSharing));
    expect(WidgetAppGroup.dataKeys, contains(WidgetAppGroup.loveCompassBearing));
    expect(WidgetAppGroup.dataKeys, contains(WidgetAppGroup.loveCompassDirection));
  });

  test('WidgetAppGroup style key generation', () {
    final key = WidgetAppGroup.styleKey('days_together', 'themeColorId');
    expect(key, equals('days_together_themeColorId'));
  });
}
