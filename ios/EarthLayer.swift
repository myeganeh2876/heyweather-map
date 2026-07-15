import Foundation
import SwiftUI

enum EarthLayer: String, CaseIterable, Identifiable {
    case wind
    case temp
    case rh
    case tcw
    case precip
    case pm25
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .wind: return "Wind Speed"
        case .temp: return "Temperature"
        case .rh: return "Relative Humidity"
        case .tcw: return "Total Cloud Water"
        case .precip: return "3 Hour Precipitation"
        case .pm25: return "Particulate Matter 2.5"
        }
    }
    
    var unitLabel: String {
        switch self {
        case .wind: return "km/h"
        case .temp: return "°C"
        case .rh: return "%"
        case .tcw: return "kg/m²"
        case .precip: return "mm"
        case .pm25: return "μg/m³"
        }
    }
    
    var icon: String {
        switch self {
        case .wind: return "wind"
        case .temp: return "thermometer"
        case .rh: return "drop"
        case .tcw: return "cloud"
        case .precip: return "cloud.rain"
        case .pm25: return "aqi.medium"
        }
    }
    
    var gradient: Gradient {
        switch self {
        case .wind:
            return Gradient(colors: [.white, .cyan, .blue, .purple, .pink])
        case .temp:
            return Gradient(colors: [.blue, .cyan, .green, .yellow, .orange, .red])
        case .rh:
            return Gradient(colors: [.white, .green, .blue])
        case .tcw:
            return Gradient(colors: [.white, .gray, .blue])
        case .precip:
            return Gradient(colors: [.white, .green, .yellow, .orange, .red, .purple])
        case .pm25:
            return Gradient(colors: [.green, .yellow, .orange, .red, .purple, .init(red: 0.3, green: 0.1, blue: 0.1)])
        }
    }
    
    var scaleValues: [String] {
        switch self {
        case .wind: return ["0", "50", "100", "150", "200", "250"]
        case .temp: return ["-40", "-20", "0", "20", "40"]
        case .rh: return ["0", "25", "50", "75", "100"]
        case .tcw: return ["0", "10", "20", "40", "60"]
        case .precip: return ["0", "1", "5", "10", "25", "50"]
        case .pm25: return ["0", "50", "150", "250", "350", "500"]
        }
    }
}
