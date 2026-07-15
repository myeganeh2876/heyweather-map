import Foundation
import WebKit
import Combine

class EarthMapViewModel: NSObject, ObservableObject {
    weak var webView: WKWebView?
    
    @Published var currentLayer: EarthLayer = .wind
    @Published var renderedDate: String = "Loading..."
    
    // Properties for HeyWeather TimeLineView compatibility
    @Published var isPlayed: Bool = false
    @Published var date: Date = Date()
    @Published var isLayersViewOpen: Bool = false
    @Published var newTimeStampSelected: Bool = false
    @Published var mapData = MapData()
    
    @Published var logs: [String] = []
    
    private var playbackTimer: Timer?
    private let stepInterval: TimeInterval = 3600 // 1-hour steps
    
    struct MapData {
        var steps: [TimeInterval] = []
        var from: Date = Date()
        var to: Date = Date()
        
        init() {
            let now = Date()
            
            // Round to the nearest UTC hour to match the Python download script's rounding logic.
            // This prevents discrepancy caused by local vs UTC rounding offsets.
            let utcTimestamp = floor(now.timeIntervalSince1970 / 3600) * 3600
            let roundedNow = Date(timeIntervalSince1970: utcTimestamp)
            
            self.from = roundedNow.addingTimeInterval(-12 * 3600)
            self.to = roundedNow.addingTimeInterval(72 * 3600)
            
            // Generate steps from -12H to +72H in 1-hour increments (85 steps total)
            for i in 0...84 {
                steps.append(from.addingTimeInterval(TimeInterval(i * 3600)).timeIntervalSince1970)
            }
        }
    }
    
    func appendLog(_ message: String) {
        DispatchQueue.main.async {
            self.logs.append(message)
        }
    }
    
    // MARK: - API Methods
    
    func setLayer(_ layer: EarthLayer) {
        currentLayer = layer
        evaluateJS("window.EarthBridge.setLayer('\(layer.rawValue)')")
    }
    
    func updateTimeFromSlider(at index: Int) {
        guard index >= 0 && index < mapData.steps.count else { return }
        let targetDate = Date(timeIntervalSince1970: mapData.steps[index])
        self.date = targetDate
        setDateTime(targetDate)
    }
    
    private func setDateTime(_ date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone(identifier: "UTC")
        let dateStr = formatter.string(from: date)
        evaluateJS("window.EarthBridge.setDateTime('\(dateStr)')")
    }
    
    func togglePlayback() {
        isPlayed.toggle()
    }
    
    // MARK: - Internal Helpers
    
    private func evaluateJS(_ script: String) {
        webView?.evaluateJavaScript(script) { result, error in
            if let error = error {
                print("JS Error: \(error.localizedDescription)")
            }
        }
    }
    
    // Poll for date updates to keep renderedDate sync'd
    func startPollingDate() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.webView?.evaluateJavaScript("window.EarthBridge ? window.EarthBridge.getRenderedDate() : null") { result, error in
                if let dateStr = result as? String {
                    DispatchQueue.main.async {
                        self?.renderedDate = dateStr
                    }
                }
            }
        }
    }
}
