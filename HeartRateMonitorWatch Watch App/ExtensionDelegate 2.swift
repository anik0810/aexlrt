//
//  ExtensionDelegate 2.swift
//  HeartRateMonitor
//
//  Created by Devangi Agarwal on 30/09/24.
//


import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {
    
    // Called when the Watch app has finished launching
    func applicationDidFinishLaunching() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("WCSession activated on Watch")
        }
    }

    // MARK: - WCSessionDelegate Methods
    
    // Called when the WCSession activation has completed
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    // Called when a message is received from the iPhone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Message received from iPhone: \(message)")
    }
    
    // Called when the iPhone becomes reachable
    func sessionReachabilityDidChange(_ session: WCSession) {
        if session.isReachable {
            print("iPhone is now reachable")
        } else {
            print("iPhone is not reachable")
        }
    }
    
    // Optional: Handle application context updates if needed
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        if let heartRate = applicationContext["heartRate"] as? Double {
            print("Application context received with heart rate: \(heartRate)")
        } else {
            print("Application context data is nil")
        }
    }
}
