import SwiftUI

struct ContentView: View {
    // The ViewModel manages the state shared between the Map (WebView) and the Controls (UI)
    @StateObject private var viewModel = EarthMapViewModel()
    
    var body: some View {
        ZStack {
            // 1. The Map Layer (Background)
            // We ignore safe area to let the map fill the entire screen, including behind the notch/island
            EarthWebView(viewModel: viewModel)
                .ignoresSafeArea()
            
            // 2. The Controls Layer (Foreground)
            VStack {
                ColorLegendView(layer: viewModel.currentLayer)
                    .padding(.top, 16)
                    .padding(.horizontal, 16)
                
                Spacer()
                
                // This view contains its own layout (Spacer + Glass Panel) so it sits at the bottom
                LayersControlView(viewModel: viewModel)
            }
        }
        .statusBar(hidden: true) // Optional: Immersive feel
    }
}

#Preview {
    ContentView()
}
