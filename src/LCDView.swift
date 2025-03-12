struct LCDView: View {
    var body: some View {
        ZStack {
            MetalLCDView()
                .frame(width: 400, height: 120)

            VStack {
                Text("LCDView")
                    .font(.custom("Courier", size: 18))
                    .foregroundColor(.green)
                    .bold()
                
                Image("wave_table")
                    .resizable()
                    .frame(width: 360, height: 40)
                    .opacity(0.7)  // Faint waveform
                
                HStack {
                    Text("MIDI IN")
                        .font(.system(size: 12))
                        .foregroundColor(.green)
                    MIDIStatusView()
                }
            }
        }
        .background(Color.black)
        .cornerRadius(8)
        .shadow(radius: 5)
    }
}