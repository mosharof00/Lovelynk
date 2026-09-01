import '../../../gen/assets.gen.dart';

/// Maps OpenWeather condition codes (+ day/night) to our 9 custom SVG icons.
///
/// When Supabase/Edge Function returns weather, pass `weather[0].id` and
/// whether the partner's local time is day or night (`icon` ends with `d`/`n`).
class WeatherIconMapper {
  WeatherIconMapper._();

  static String iconFor({
    required int conditionId,
    bool isDay = true,
  }) {
    if (conditionId >= 200 && conditionId < 300) {
      return Assets.weatherIcons.weatherThunderstorm;
    }
    if (conditionId >= 300 && conditionId < 400) {
      return Assets.weatherIcons.weatherDrizzle;
    }
    if (conditionId >= 500 && conditionId < 600) {
      return Assets.weatherIcons.weatherRain;
    }
    if (conditionId >= 600 && conditionId < 700) {
      return Assets.weatherIcons.weatherSnow;
    }
    if (conditionId >= 700 && conditionId < 800) {
      return Assets.weatherIcons.weatherFog;
    }
    if (conditionId == 800) {
      return isDay
          ? Assets.weatherIcons.weatherClearDay
          : Assets.weatherIcons.weatherClearNight;
    }
    if (conditionId == 801) {
      return Assets.weatherIcons.weatherPartlyCloudy;
    }
    if (conditionId > 801 && conditionId < 900) {
      return Assets.weatherIcons.weatherClouds;
    }
    return Assets.weatherIcons.weatherPartlyCloudy;
  }

  /// Key synced to the iOS widget extension (maps to SF Symbols there).
  static String nativeIconKey({
    required int conditionId,
    bool isDay = true,
  }) {
    if (conditionId >= 200 && conditionId < 300) return 'thunderstorm';
    if (conditionId >= 300 && conditionId < 400) return 'drizzle';
    if (conditionId >= 500 && conditionId < 600) return 'rain';
    if (conditionId >= 600 && conditionId < 700) return 'snow';
    if (conditionId >= 700 && conditionId < 800) return 'fog';
    if (conditionId == 800) return isDay ? 'clear_day' : 'clear_night';
    if (conditionId == 801) return 'partly_cloudy';
    if (conditionId > 801 && conditionId < 900) return 'clouds';
    return 'partly_cloudy';
  }

  /// Parses OpenWeather `weather[0].icon` suffix (`01d` → day, `01n` → night).
  static bool isDayFromIconCode(String? iconCode) {
    if (iconCode == null || iconCode.isEmpty) return true;
    return iconCode.endsWith('d');
  }
}
