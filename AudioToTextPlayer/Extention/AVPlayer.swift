//
//  AVPlayer.swift
//  AudioToText
//
//  Created by Viktor Kushnerov on 19.12.21.
//

import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
