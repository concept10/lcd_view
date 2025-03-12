import SwiftUI

@main
struct LCDViewApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var displayText = "HELLO WORLD"
    @State private var showWaveform = true
    @State private var midiActive = true
    
    var body: some View {
        VStack {
            LCDView(text: displayText, showWaveform: showWaveform, midiActive: midiActive)
                .frame(width: 600, height: 300)
                .padding()
            
            Text("LCD Display Demo")
                .font(.title)
            
            HStack {
                Button("Toggle Waveform") {
                    showWaveform.toggle()
                }
                Spacer()
                Button("Toggle MIDI Status") {
                    midiActive.toggle()
                }
            }
            .padding()
        }
        .frame(minWidth: 640, minHeight: 480)
    }
}