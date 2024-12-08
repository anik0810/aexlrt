
import Foundation
import WatchConnectivity

class WatchConnectionManager: NSObject, ObservableObject, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: (any Error)?) {
        print("YES")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("YES")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("YES")
    }
    
    @Published var heartRate: Double = 0.0
    
    override init() {
        super.init()
        setupWatchConnectivity()
    }
    
    private func setupWatchConnectivity() {
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func session(_: WCSession, didReceiveMessage message: [String: Any]) {
        if let heartRate = message["heartRate"] as? Double {
            DispatchQueue.main.async {
                self.heartRate = heartRate
            }
        }
    }
}
