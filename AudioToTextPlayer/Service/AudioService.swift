//
//  AudioService.swift
//  AudioToText
//
//  Created by Viktor Kushnerov on 19.12.21.
//

import Speech
import SwiftUI

class AudioService: NSObject, ObservableObject {
    static let shared = AudioService()

    var player = AVQueuePlayer()

    private var recognitionTask: SFSpeechRecognitionTask?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private let speechRecognizer = SFSpeechRecognizer()!
    private var tap: MYAudioTapProcessor!
    private var playerItem: AVPlayerItem!

    @Published var text: String = ""

    @AppStorage("url") var url: String = "https://devstreaming-cdn.apple.com/videos/wwdc/2016/509n1cnykqms19r9jyp/509/509_sd_speech_recognition_api.mp4?dl=1"

    func start() {
        guard let url = URL(string: url) else { return }
        let asset = AVURLAsset(url: url)
        guard let audioTrack = asset.tracks(withMediaType: AVMediaType.audio).first else {
            print("can't get audioTrack")
            return
        }

        playerItem = AVPlayerItem(asset: asset)

        // Taken from https://github.com/zats/SpeechRecognition
        tap = MYAudioTapProcessor(audioAssetTrack: audioTrack)
        tap.delegate = self

        player.insert(playerItem, after: nil)
        player.currentItem?.audioMix = tap.audioMix
        player.play()

        setupRecognition()
    }

    func restart() {
        player.removeAllItems()
        start()
    }

    private func setupRecognition() {
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()

        recognitionRequest.requiresOnDeviceRecognition = true

        // we want to get continuous recognition and not everything at once at the end of the video
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, _ in
            guard let result = result, let self = self else { return }

            self.text = result.bestTranscription.formattedString

            // once in about every minute recognition task finishes so we need to set up a new one to continue recognition
            if result.isFinal == true {
                self.recognitionRequest = nil
                self.recognitionTask = nil

                self.setupRecognition()
            }
        }
        self.recognitionRequest = recognitionRequest
    }

    func seek(seconds: Float64) {
        guard let duration = player.currentItem?.duration else {
            return
        }
        let playerCurrentTime = CMTimeGetSeconds(player.currentTime())
        let newTime = playerCurrentTime + seconds

        if newTime < CMTimeGetSeconds(duration) {
            let time2: CMTime = CMTimeMake(value: Int64(newTime * 1000 as Float64), timescale: 1000)

            player.seek(to: time2, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero)
        }
    }
}

extension AudioService: MYAudioTabProcessorDelegate {
    // getting audio buffer back from the tap and feeding into speech recognizer
    func audioTabProcessor(_ audioTabProcessor: MYAudioTapProcessor!, didReceive buffer: AVAudioPCMBuffer!) {
        recognitionRequest?.append(buffer)
    }
}
