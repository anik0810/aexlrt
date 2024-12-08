import SwiftUI

struct ContentView: View {
    @StateObject private var watchConnectionManager = WatchConnectionManager()
    
    var body: some View {
        VStack {
            Text("Real-Time Heart Rate")
                .font(.title)
                .padding()
            
            Text("\(watchConnectionManager.heartRate, specifier: "%.1f") BPM")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding()
        }
    }
}
