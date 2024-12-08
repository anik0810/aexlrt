import WatchKit
import WatchConnectivity
import AVFoundation

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    override init() {
        super.init()
        setupWCSession()
    }
    
    // Initialize WCSession for communication with iPhone
    private func setupWCSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("WCSession activated with state: \(session.activationState.rawValue)")
        }
    }

    // Watch app's lifecycle methods
    func applicationDidFinishLaunching() {
        print("Watch app launched")
    }

    func applicationDidBecomeActive() {
        print("Watch app became active")
    }

    func applicationWillResignActive() {
        print("Watch app will resign active")
    }
    
    // MARK: - WCSessionDelegate Methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            print("iPhone is reachable")
        } else {
            print("iPhone is not reachable")
        }
    }
   

    func configureAudioSession() {
        do {
            // Set the audio session category to playback
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            
            // Activate the audio session
            try AVAudioSession.sharedInstance().setActive(true)
            
            print("Audio session configured for background playback.")
        } catch {
            print("Error configuring AVAudioSession: \(error.localizedDescription)")
        }
    }

}


