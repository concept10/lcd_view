import SwiftUI

struct MIDIStatusView: View {
    @State private var isActive = false
    
    var body: some View {
        Circle()
            .fill(isActive ? Color.green : Color.gray)
            .frame(width: 10, height: 10)
            .onAppear {
                // Simulated MIDI input
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    isActive.toggle()
                }
            }
    }
}