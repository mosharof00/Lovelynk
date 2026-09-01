import SwiftUI

enum WidgetWeatherIcon {
    static func systemName(for key: String) -> String {
        switch key {
        case "thunderstorm": return "cloud.bolt.rain.fill"
        case "drizzle": return "cloud.drizzle.fill"
        case "rain": return "cloud.rain.fill"
        case "snow": return "cloud.snow.fill"
        case "fog": return "cloud.fog.fill"
        case "clear_day": return "sun.max.fill"
        case "clear_night": return "moon.stars.fill"
        case "clouds": return "cloud.fill"
        default: return "cloud.sun.fill"
        }
    }

    static func emoji(for key: String) -> String {
        switch key {
        case "thunderstorm": return "⛈️"
        case "drizzle", "rain": return "🌧️"
        case "snow": return "❄️"
        case "fog": return "🌫️"
        case "clear_day": return "☀️"
        case "clear_night": return "🌙"
        case "clouds": return "☁️"
        default: return "⛅"
        }
    }
}
