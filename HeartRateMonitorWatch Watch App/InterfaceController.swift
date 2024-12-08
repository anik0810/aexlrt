//
//  InterfaceController.swift
//  HeartRateMonitor
//
//  Created on 19/11/2024.
//

//import WatchKit
//import Foundation
//
//class InterfaceController: WKInterfaceController {
//    
//    override func awake(withContext context: Any?) {
//        super.awake(withContext: context)
//    }
//    
//    override func willActivate() {
//        super.willActivate()
//        // Prevent screen from timing out
//        WKExtension.shared().isIdleTimerDisabled = true
//    }
//    
//    override func didDeactivate() {
//        // Reset screen timeout when view deactivates
//        WKExtension.shared().isIdleTimerDisabled = false
//        super.didDeactivate()
//    }
//}
//import WatchKit
//import HealthKit
//
//class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
//    private var healthStore = HKHealthStore()
//    private var workoutSession: HKWorkoutSession?
//
//    override func willActivate() {
//        super.willActivate()
//        startWorkoutSession()
//    }
//
//    override func didDeactivate() {
//        stopWorkoutSession()
//        super.didDeactivate()
//    }
//
//    private func startWorkoutSession() {
//        guard HKHealthStore.isHealthDataAvailable() else { return }
//
//        let configuration = HKWorkoutConfiguration()
//        configuration.activityType = .running
//        configuration.locationType = .outdoor
//
//        do {
//            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
//            workoutSession?.delegate = self
//            workoutSession?.startActivity(with: Date())
//            print("Workout session started.")
//        } catch {
//            print("Failed to start workout session: \(error.localizedDescription)")
//        }
//    }
//
//    private func stopWorkoutSession() {
//        workoutSession?.stopActivity(with: Date())
//        workoutSession = nil
//        print("Workout session stopped.")
//    }
//
//    // MARK: - HKWorkoutSessionDelegate
//    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
//        print("Workout session failed with error: \(error.localizedDescription)")
//    }
//
//    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
//        print("Workout session changed from \(fromState) to \(toState)")
//    }
//}


//import WatchKit
//
//class InterfaceController: WKInterfaceController, WKExtendedRuntimeSessionDelegate {
//    private var extendedRuntimeSession: WKExtendedRuntimeSession?
//
//    override func willActivate() {
//        super.willActivate()
//        startExtendedRuntimeSession()
//    }
//
//    override func didDeactivate() {
//        stopExtendedRuntimeSession()
//        super.didDeactivate()
//    }
//
//    private func startExtendedRuntimeSession() {
//        if extendedRuntimeSession == nil {
//            extendedRuntimeSession = WKExtendedRuntimeSession()
//            extendedRuntimeSession?.delegate = self
//        }
//        extendedRuntimeSession?.start()
//        print("Extended runtime session started.")
//    }
//
//    private func stopExtendedRuntimeSession() {
//        extendedRuntimeSession?.invalidate()
//        print("Extended runtime session stopped.")
//    }
//
//    // MARK: - WKExtendedRuntimeSessionDelegate
//    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
//        print("Extended runtime session did start.")
//    }
//
//    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
//        print("Extended runtime session will expire soon.")
//    }
//
//    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
//        if let error = error {
//            print("Runtime session invalidated with error: \(error.localizedDescription)")
//        } else {
//            print("Runtime session invalidated with reason: \(reason.rawValue)")
//        }
//    }
//}

//latest code
//import WatchKit
//import AVFoundation
//
//class InterfaceController: WKInterfaceController, WKExtendedRuntimeSessionDelegate {
//    private var extendedRuntimeSession: WKExtendedRuntimeSession?
//    private var audioPlayer: AVAudioPlayer?
//
//    override func awake(withContext context: Any?) {
//        super.awake(withContext: context)
//        configureAudioSession()
//    }
//
//    override func willActivate() {
//        super.willActivate()
//        startBackgroundMusic()
//        startExtendedRuntimeSession()
//    }
//
//    override func didDeactivate() {
//        stopBackgroundMusic()
//        stopExtendedRuntimeSession()
//        super.didDeactivate()
//    }
//
//    // MARK: - Configure Audio Session
//    private func configureAudioSession() {
//        do {
//            let audioSession = AVAudioSession.sharedInstance()
//            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowBluetooth])
//            try audioSession.setActive(true)
//            print("Audio session configured for background playback.")
//        } catch {
//            print("Failed to configure audio session: \(error.localizedDescription)")
//        }
//    }
//
//    // MARK: - Background Music Management
//    private func startBackgroundMusic() {
//        guard let audioFilePath = Bundle.main.path(forResource: "background_music", ofType: "mp3") else {
//            print("Audio file not found.")
//            return
//        }
//
//        do {
//            let audioFileURL = URL(fileURLWithPath: audioFilePath)
//            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
//            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
//            audioPlayer?.prepareToPlay()
//            audioPlayer?.play()
//            print("Background music started.")
//        } catch {
//            print("Failed to initialize audio player: \(error.localizedDescription)")
//        }
//    }
//
//    private func stopBackgroundMusic() {
//        audioPlayer?.stop()
//        print("Background music stopped.")
//    }
//
//    // MARK: - WKExtendedRuntimeSession Management
//    private func startExtendedRuntimeSession() {
//        if extendedRuntimeSession == nil {
//            extendedRuntimeSession = WKExtendedRuntimeSession()
//            extendedRuntimeSession?.delegate = self
//        }
//        extendedRuntimeSession?.start()
//        print("Extended runtime session started.")
//    }
//
//    private func stopExtendedRuntimeSession() {
//        extendedRuntimeSession?.invalidate()
//        print("Extended runtime session stopped.")
//    }
//
//    // MARK: - WKExtendedRuntimeSessionDelegate
//    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
//        print("Extended runtime session did start.")
//    }
//
//    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
//        print("Extended runtime session will expire soon.")
//    }
//
//    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
//        if let error = error {
//            print("Runtime session invalidated with error: \(error.localizedDescription)")
//        } else {
//            print("Runtime session invalidated with reason: \(reason.rawValue)")
//        }
//    }
//}
import WatchKit
import AVFoundation

class InterfaceController: WKInterfaceController, WKExtendedRuntimeSessionDelegate {
    private var audioPlayer: AVAudioPlayer?
    private var extendedRuntimeSession: WKExtendedRuntimeSession?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        configureAudioSession()
        prepareAudioPlayer()
    }

    override func willActivate() {
        super.willActivate()
        startAudioPlayback()
        startExtendedRuntimeSession()
    }

    override func didDeactivate() {
        super.didDeactivate()
        // Do NOT stop the audio player to allow background playback.
        stopExtendedRuntimeSession()
    }

    // MARK: - Configure Audio Session
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            print("Audio session configured for playback.")
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
    }

    // MARK: - Prepare Audio Player
    private func prepareAudioPlayer() {
        guard let audioFilePath = Bundle.main.path(forResource: "/Users/devangiagarwal/Desktop/Heart Rate/HeartRateMonitor/MainTrack 3.wav", ofType: "wav") else {
            print("Audio file not found.")
            return
        }

        do {
            let audioFileURL = URL(fileURLWithPath: audioFilePath)
            audioPlayer = try AVAudioPlayer(contentsOf: audioFileURL)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
            print("Audio player prepared.")
        } catch {
            print("Failed to initialize audio player: \(error.localizedDescription)")
        }
    }

    private func startAudioPlayback() {
        audioPlayer?.play()
        print("Audio playback started.")
    }

    // MARK: - WKExtendedRuntimeSession Management
    private func startExtendedRuntimeSession() {
        if extendedRuntimeSession == nil {
            extendedRuntimeSession = WKExtendedRuntimeSession()
            extendedRuntimeSession?.delegate = self
        }
        extendedRuntimeSession?.start()
        print("Extended runtime session started.")
    }

    private func stopExtendedRuntimeSession() {
        extendedRuntimeSession?.invalidate()
        extendedRuntimeSession = nil
        print("Extended runtime session stopped.")
    }

    // MARK: - WKExtendedRuntimeSessionDelegate
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended runtime session did start.")
    }

    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("Extended runtime session will expire soon.")
        // Optional: Restart session or notify user.
    }

    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        if let error = error {
            print("Runtime session invalidated with error: \(error.localizedDescription)")
        } else {
            print("Runtime session invalidated with reason: \(reason.rawValue)")
        }
    }
}





