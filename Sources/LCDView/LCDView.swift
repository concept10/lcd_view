import SwiftUI

struct LCDView: View {
    var text: String
    var showWaveform: Bool
    var midiActive: Bool
    
    // Generate sample waveform data
    private var waveformData: [Float] {
        (0..<128).map { i in
            let x = Float(i) / 128.0
            return sin(x * 10.0) * 0.5 + 0.5
        }
    }
    
    var body: some View {
        ZStack {
            // Use MetalLCDView for rendering
            MetalLCDView(textureData: waveformData, text: text, midiActive: midiActive)
            
            if !showWaveform {
                // Cover waveform with black rectangle when disabled
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .frame(height: 40)
                    .offset(y: 20)
            }
            
            // MIDI status indicator at bottom right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HStack(spacing: 4) {
                        Text("MIDI")
                            .font(.system(size: 12))
                            .foregroundColor(.green)
                        Circle()
                            .fill(midiActive ? Color.green : Color.gray)
                            .frame(width: 8, height: 8)
                    }
                    .padding(8)
                }
            }
        }
        .background(Color.black)
        .cornerRadius(4)
    }
}
