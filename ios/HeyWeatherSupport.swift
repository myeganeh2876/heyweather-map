import SwiftUI

struct Constants {
    static let accentColor = Color(red: 251/255, green: 191/255, blue: 36/255) // Standard Earth-AE gold
    static let commaAndSpace = ", "
    
    struct SystemIcons {
        static let circlePause = "pause.circle.fill"
        static let circlePlay = "play.circle.fill"
    }
    
    struct Icons {
        static let mapLayers = "layers.fill"
    }
}

// Extensions to satisfy the snippet
extension Date {
    var shortWeekday: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
    
    func toUserTimeFormatWithMinutes() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    var shortLocalizedString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    func isRealNow(timezone: TimeZone) -> Bool {
        return abs(self.timeIntervalSinceNow) < 300 // Within 5 minutes
    }
}

extension String {
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
}

// Support Components
struct MapCardBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct TimelineSlider: View {
    @Binding var progress: Float
    let stepsCount: Int
    
    var body: some View {
        Slider(value: Binding(
            get: { progress },
            set: { progress = $0 }
        ), in: 0...Float(stepsCount), step: 1)
        .accentColor(Constants.accentColor)
    }
}

// View Modifiers used in snippet
extension View {
    func fonted(_ style: Font, weight: Font.Weight = .regular) -> some View {
        self.font(style.weight(weight))
    }
    
    func fonted(size: CGFloat, weight: Font.Weight = .regular) -> some View {
        self.font(.system(size: size, weight: weight))
    }
    
    func complexModifier<V: View>(@ViewBuilder _ modifier: (Self) -> V) -> some View {
        modifier(self)
    }
}
