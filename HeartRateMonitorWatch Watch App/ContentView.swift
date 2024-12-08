import SwiftUI

struct HeartRateView: View {
    @ObservedObject var healthKitManager = HealthKitManager.shared
    @State private var navigateToNextView: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("HR")
                    .font(.title)
                    .padding()
                Text("\(healthKitManager.heartRate, specifier: "%.0f") BPM")
                    .font(.largeTitle)
                    .padding()
            }
            .onAppear {
                // Request authorization when the view appears
                healthKitManager.requestAuthorization()
                
                // Use the playtime of MainTrack 3 (20 minutes)
                let playTime = 20 * 60 // 20 minutes in seconds
                let deadline = DispatchTime.now() + .seconds(playTime)
                
//                 Ensure navigateToNextView is updated on the main thread
                DispatchQueue.main.asyncAfter(deadline: deadline) {
                    DispatchQueue.main.async {
                        navigateToNextView = true
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black) // Optional: background color for the page
            .navigationDestination(isPresented: $navigateToNextView) {
                CongratulationView()
            }
        }
    }
}

struct CongratulationView: View {
    var body: some View {
        VStack {
            // Headline at the top
            Text("CONGRATULATION")
                .font(.headline)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30) // Space below the headline

            // Label at the center
            Text("YOU COMPLETED")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.bottom, 10) // Space below the label

            Text("THE MISSION!")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20) // Space below the label

            Spacer() // Push the arrow button to the bottom
        }
        .padding() // Add padding around the VStack
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it fills the screen
    }
}

struct HeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView()
    }
}
