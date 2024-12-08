import Foundation
import AVFoundation
import HealthKit
import Combine

class HealthKitManager: NSObject, ObservableObject {
    
    static let shared = HealthKitManager()
    
    private var healthStore = HKHealthStore()
    private var heartRateQuery: HKQuery?
    private var audioPlayer: AVAudioPlayer?

    // Array of timestamps 15min
    private let timestamps: [Double] = [107, 165, 212, 236, 279, 296, 420, 510, 542, 605, 615, 636, 690, 740, 775, 795, 838]

    // Maximum heart rate
    private let maxHeartRate: Double = 190

    // Target Heart rate ranges
    private let TARGET_HEART_RATES: [(Double, Double)] = [
        (0.50, 0.60), (0.60, 0.70), (0.60, 0.70), (0.64, 0.76), (0.64, 0.76),
        (0.64, 0.76), (0.77, 0.89), (0.77, 0.89), (0.77, 0.89), (0.77, 0.89),
        (0.64, 0.76), (0.64, 0.76), (0.64, 0.76), (0.64, 0.76), (0.64, 0.76),
        (0.64, 0.76), (0.64, 0.76)
    ]

    // Arrays to store the A_ and S_ track names
    private let aTracks: [String] = (1...17).map { "A_\($0) 15" }
    private let sTracks: [String] = (1...17).map { "S_\($0) 15" }

    private var playedOverlays: [Int: Bool] = [:] // To track if an overlay has already been played

    // Array to hold AVAudioPlayer references for overlay tracks
    private var overlayPlayers: [AVAudioPlayer] = []

    @Published var heartRate: Double = 0.0 {
        didSet {
            checkHeartRateForOverlay()
        }
    }

    @Published var stepCount: Int = 0
    @Published var distance: Double = 0.0
    @Published var energyBurned: Double = 0.0
    @Published var exerciseTime: Double = 0.0
    
    @Published var mainTrackPlayTime: TimeInterval = 0.0 // Track play time of main track

    private var timer: Timer?

    override init() {
        super.init()
        requestAuthorization()
        startMainTrack()
    }

    // MARK: - HealthKit Authorization
    func requestAuthorization() {
        if HKHealthStore.isHealthDataAvailable() {
            let typesToRead: Set = [
                HKObjectType.quantityType(forIdentifier: .heartRate)!,
                HKObjectType.quantityType(forIdentifier: .stepCount)!,
                HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
                HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!
            ]

            healthStore.requestAuthorization(toShare: nil, read: typesToRead) { (success, error) in
                DispatchQueue.main.async {
                    if success {
                        self.startHeartRateMonitoring()
                        self.fetchExerciseTime()
                        self.fetchStepCount()
                        self.fetchDistanceWalkingRunning()
                        self.fetchEnergyBurned()
                    } else {
                        // Handle error (optional)
                    }
                }
            }
        }
    }

    // MARK: - Heart Rate Monitoring
    func startHeartRateMonitoring() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }

        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { [weak self] (query, samples, deletedObjects, newAnchor, error) in
            DispatchQueue.main.async {
                self?.handleHeartRateSamples(samples)
            }
        }

        query.updateHandler = { [weak self] (query, samples, deletedObjects, newAnchor, error) in
            DispatchQueue.main.async {
                self?.handleHeartRateSamples(samples)
            }
        }

        healthStore.execute(query)
        heartRateQuery = query
    }

    // MARK: - Handle Heart Rate Data
    private func handleHeartRateSamples(_ samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else { return }

        DispatchQueue.main.async {
            if let sample = heartRateSamples.first {
                let heartRateUnit = HKUnit(from: "count/min")
                self.heartRate = sample.quantity.doubleValue(for: heartRateUnit)
                print("Heart Rate: \(self.heartRate)")
            }
        }
    }

    // MARK: - Fetch Other Metrics
//    func fetchOtherMetrics() {
//        fetchStepCount()
//        fetchDistanceWalkingRunning()
//        fetchEnergyBurned()
//        fetchExerciseTime()
//    }
    
    

    private func fetchStepCount() {
        fetchData(for: .stepCount, unit: HKUnit.count()) { value in
            DispatchQueue.main.async {
                self.stepCount = Int(value)
                print("Step Count: \(self.stepCount)")
            }
        }
    }

    private func fetchDistanceWalkingRunning() {
        fetchData(for: .distanceWalkingRunning, unit: HKUnit.meterUnit(with: .kilo)) { value in
            DispatchQueue.main.async {
                self.distance = value
                print("Distance: \(self.distance) km")
            }
        }
    }

    private func fetchEnergyBurned() {
        fetchData(for: .activeEnergyBurned, unit: HKUnit.kilocalorie()) { value in
            DispatchQueue.main.async {
                self.energyBurned = value
                print("Energy Burned: \(self.energyBurned) kcal")
            }
        }
    }

    private func fetchExerciseTime() {
        fetchData(for: .appleExerciseTime, unit: HKUnit.minute()) { value in
            DispatchQueue.main.async {
                self.exerciseTime = value
                print("Exercise Time: \(self.exerciseTime) minutes")
            }
        }
    }


    private func fetchData(for identifier: HKQuantityTypeIdentifier, unit: HKUnit, completion: @escaping (Double) -> Void) {
        guard let quantityType = HKObjectType.quantityType(forIdentifier: identifier) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: Calendar.current.startOfDay(for: Date()), end: Date(), options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                print("Error fetching \(identifier.rawValue): \(error?.localizedDescription ?? "Unknown error")")
                completion(0.0)
                return
            }
            DispatchQueue.main.async {
                completion(sum.doubleValue(for: unit))
            }
        }
        healthStore.execute(query)
    }

    // MARK: - Main Track Playback
    private func startMainTrack() {
        if let path = Bundle.main.path(forResource: "MainTrack 15", ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
                print("Main track started")
                startTimer()
            } catch {
                print("Failed to play MainTrack: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Timer Setup
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.checkHeartRateForOverlay()
            self?.updateMainTrackPlayTime()
        }
    }

    private func updateMainTrackPlayTime() {
        if let currentTime = audioPlayer?.currentTime {
            DispatchQueue.main.async {
                self.mainTrackPlayTime = currentTime
                print("Main track play time updated: \(self.mainTrackPlayTime) seconds")
            }
        }
    }

    // MARK: - Check Heart Rate and Play Overlay
    private func checkHeartRateForOverlay() {
        guard let currentTime = audioPlayer?.currentTime else { return }

        for (index, timestamp) in timestamps.enumerated() {
            if currentTime >= timestamp, playedOverlays[index] == nil {
                playedOverlays[index] = true
                playOverlay(for: index)
                break
            }
        }
    }

    // MARK: - Play Overlay Audio
    private func playOverlay(for index: Int) {
        guard index < aTracks.count, index < sTracks.count else { return }
        let targetHeartRateRange = TARGET_HEART_RATES[index]

        // Determine if the current heart rate is within target range
        let targetHeartRate = maxHeartRate * targetHeartRateRange.0
        let upperTargetHeartRate = maxHeartRate * targetHeartRateRange.1
        
        if heartRate >= targetHeartRate && heartRate <= upperTargetHeartRate {
            let overlayTrack = aTracks[index]
            if let path = Bundle.main.path(forResource: overlayTrack, ofType: "wav") {
                let url = URL(fileURLWithPath: path)
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.play()
                    overlayPlayers.append(player)
                    print("Playing overlay: \(overlayTrack)")
                } catch {
                    print("Error playing overlay: \(error.localizedDescription)")
                }
            }
        } else {
            // Play the secondary overlay
            let overlayTrack = sTracks[index]
            if let path = Bundle.main.path(forResource: overlayTrack, ofType: "wav") {
                let url = URL(fileURLWithPath: path)
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.play()
                    overlayPlayers.append(player)
                    print("Playing secondary overlay: \(overlayTrack)")
                } catch {
                    print("Error playing secondary overlay: \(error.localizedDescription)")
                }
            }
        }
    }
}

