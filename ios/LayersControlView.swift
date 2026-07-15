import SwiftUI

struct LayersControlView: View {
    @ObservedObject var viewModel: EarthMapViewModel
    
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    @State var progress: Float = 0.0
    
    var body: some View {
        ZStack {
            MapCardBackground()
            
            VStack(spacing: -2) {
                HStack(spacing: 12) {
                    // Play/Pause Button
                    Button {
                        viewModel.togglePlayback()
                    } label: {
                        Image(systemName: viewModel.isPlayed ? Constants.SystemIcons.circlePause : Constants.SystemIcons.circlePlay)
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(Constants.accentColor, Color(.systemBackground).opacity(0.5))
                            .tint(Constants.accentColor.opacity(0.2))
                            .fonted(.title, weight: .regular)
                            .complexModifier({ view in
                                if #available(iOS 17.0, *) {
                                    view.symbolEffect(.bounce, value: viewModel.isPlayed)
                                } else {
                                    view
                                }
                            })
                    }
                    Text(viewModel.date.shortWeekday + Constants.commaAndSpace + viewModel.date.toUserTimeFormatWithMinutes())
                        .contentTransition(.numericText())
                        .monospacedDigit()
                        .fonted(.subheadline, weight: .semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Layer Menu
                    Menu {
                        ForEach(EarthLayer.allCases) { layer in
                            Button(action: { viewModel.setLayer(layer) }) {
                                Label {
                                    Text(layer.displayName)
                                } icon: {
                                    if viewModel.currentLayer == layer {
                                        Image(systemName: "checkmark")
                                    } else {
                                        Image(systemName: layer.icon)
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(Constants.Icons.mapLayers)
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                if !viewModel.mapData.steps.isEmpty {
                    TimelineSlider(progress: $progress, stepsCount: viewModel.mapData.steps.count - 1)
                        .padding(.top, 6)
                        .padding(.bottom, 4)
                    
                    GeometryReader { geo in
                        let sliderInternalPadding: CGFloat = 8 // Standard SwiftUI Slider padding
                        let trackWidth = geo.size.width - (sliderInternalPadding * 2)
                        let stepWidth = trackWidth / CGFloat(viewModel.mapData.steps.count - 1)
                        
                        ZStack(alignment: .leading) {
                            // Boundary Labels
                            HStack {
                                Text(viewModel.mapData.from.shortLocalizedString)
                                Spacer()
                                Text(viewModel.mapData.to.shortLocalizedString)
                            }
                            .fonted(.caption, weight: .bold)
                            .opacity(0.6)
                            .foregroundColor(.white)
                            
                            // Center "Now" Label
                            if let nowIndex = viewModel.mapData.steps.firstIndex(where: { Date(timeIntervalSince1970: $0).isRealNow(timezone: .current) }) {
                                let nowOffset = sliderInternalPadding + (stepWidth * CGFloat(nowIndex))
                                
                                Text("Now")
                                    .fonted(size: 10, weight: .bold)
                                    .foregroundColor(Constants.accentColor)
                                    .padding(.horizontal, 4)
                                    .background(Color.black.opacity(0.4))
                                    .cornerRadius(4)
                                    .offset(x: nowOffset - 12)
                            }
                        }
                    }
                    .frame(height: 14)
                }
            }
            .padding(.horizontal, 6)
            .padding(8)
            .frame(height: 90)
            .onAppear {
                if let index = viewModel.mapData.steps.firstIndex(where: { $0 >= viewModel.date.timeIntervalSince1970 }) {
                    progress = Float(index)
                }
            }
            .onChange(of: progress) { newValue in
                let index = Int(round(newValue))
                if index >= 0 && index < viewModel.mapData.steps.count {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.updateTimeFromSlider(at: index)
                    }
                    viewModel.newTimeStampSelected = true
                }
            }
            .onReceive(timer) { _ in
                if viewModel.isPlayed {
                    withAnimation(.linear(duration: 0.5)) {
                        if progress >= Float(viewModel.mapData.steps.count - 1) {
                            progress = 0
                        } else {
                            progress += 1
                        }
                    }
                }
            }
        }
        .frame(height: 90)
    }
}
