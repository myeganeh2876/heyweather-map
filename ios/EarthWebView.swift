import SwiftUI
import WebKit

struct EarthWebView: UIViewRepresentable {
    @ObservedObject var viewModel: EarthMapViewModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        // Allow local file access
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        config.setValue(true, forKey: "allowUniversalAccessFromFileURLs")
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        
        // Inject Console Log Handler
        let source = """
        function captureLog(type, args) {
            var msg = Array.from(args).map(String).join(" ");
            window.webkit.messageHandlers.console.postMessage(type + ": " + msg);
        }
        window.console.log = function(...args) { captureLog("JS LOG", args); }
        window.console.error = function(...args) { captureLog("JS ERROR", args); }
        window.console.warn = function(...args) { captureLog("JS WARN", args); }
        """
        let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.addUserScript(script)
        config.userContentController.add(context.coordinator, name: "console")
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        viewModel.webView = webView
        
        // Load Remote URL
        if let url = URL(string: "https://map.momentumapp.sbs") {
             viewModel.appendLog("[EarthWebView] Loading remote URL: \(url)")
             let request = URLRequest(url: url)
             webView.load(request)
        } else {
             viewModel.appendLog("[EarthWebView] ERROR: Invalid URL")
        }
        
        // Disable scrolling to feel like a native map
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.isOpaque = false
        webView.backgroundColor = UIColor(red: 0, green: 0, blue: 5.0/255.0, alpha: 1.0)
        
        viewModel.startPollingDate()
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // ViewModel updates happen via direct JS calls
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        var parent: EarthWebView
        
        init(_ parent: EarthWebView) {
            self.parent = parent
        }
        
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if let body = message.body as? String {
                print("[WebView] \(body)")
                parent.viewModel.appendLog(body)
            }
        }
        
        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            parent.viewModel.appendLog("[EarthWebView] Started loading content...")
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.viewModel.appendLog("[EarthWebView] Finished loading content.")
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.appendLog("[EarthWebView] Failed loading: \(error.localizedDescription)")
        }
        
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            parent.viewModel.appendLog("[EarthWebView] Failed provisional nav: \(error.localizedDescription)")
        }
    }
}
