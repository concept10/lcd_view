import SwiftUI

struct LCDView_Previews: PreviewProvider {
    static var previews: some View {
        LCDView(text: "PREVIEW TEXT", showWaveform: true, midiActive: true)
            .frame(width: 500, height: 200)
            .padding()
    }
}