//
//  AudioManager.swift
//  HeartRateMonitor
//
//  Created by Devangi Agarwal on 17/09/24.
//
import AVFoundation

class AudioManager {
    static let shared = AudioManager() // Singleton instance
    private init() {} // Private initializer to enforce singleton
    
    var audioPlayer: AVPlayer?
    var aSeriesPlayers = [AVPlayer]()
    var sSeriesPlayers = [AVPlayer]()
    
    let mainTrackURL = Bundle.main.url(forResource: "MainTrack", withExtension: "wav")
    let aSeriesURLs = (1...19).map { Bundle.main.url(forResource: "A_\($0)", withExtension: "wav")! }
    let sSeriesURLs = (1...19).map { Bundle.main.url(forResource: "S_\($0)", withExtension: "wav")! }
    
    func setupMainTrack() {
        guard let url = mainTrackURL else {
            print("Main track file not found")
            return
        }
        audioPlayer = AVPlayer(url: url)
        audioPlayer?.play()
    }
    
    func playSeriesTrack(at index: Int, isHigher: Bool) {
        guard index > 0 && index <= aSeriesURLs.count else {
            print("Invalid index for series track")
            return
        }
        
        let url = isHigher ? sSeriesURLs[index - 1] : aSeriesURLs[index - 1]
        let player = AVPlayer(url: url)
        player.play()
        
        if isHigher {
            sSeriesPlayers.append(player)
        } else {
            aSeriesPlayers.append(player)
        }
    }
}

