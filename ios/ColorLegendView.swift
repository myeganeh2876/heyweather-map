import SwiftUI

struct ColorLegendView: View {
    let layer: EarthLayer
    
    var body: some View {
        ZStack {
            MapCardBackground()
            
            VStack(spacing: 8) {
                // Header: Layer Name and Unit
                HStack(alignment: .firstTextBaseline) {
                    Text(layer.displayName)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(layer.unitLabel)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
                
                // The Gradient Scale
                RoundedRectangle(cornerRadius: 5)
                    .fill(LinearGradient(
                        gradient: layer.gradient,
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .frame(height: 10)
                
                // The Numeric Indicators
                HStack(spacing: 0) {
                    ForEach(layer.scaleValues, id: \.self) { value in
                        Text(value)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(14)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.black
        ColorLegendView(layer: .wind)
    }
}
