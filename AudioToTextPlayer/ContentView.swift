//
//  ContentView.swift
//  AudioToText
//
//  Created by Viktor Kushnerov on 19.12.21.
//

import AVKit
import SwiftUI

struct ContentView: View {
    @ObservedObject var audioService = AudioService.shared
    @State var height: CGFloat = 50

    var body: some View {
        VStack {
            TextField("Enter audio or video url", text: $audioService.url)
                .onSubmit {
                    audioService.restart()
                }
            
            VideoPlayer(player: audioService.player)
                .frame(width: 700, height: height)
                .onAppear {
                    audioService.start()
                }

            HStack {
                Button {
                    height = height == 50 ? 300 : 50
                } label: {
                    Image(systemName: height == 50 ? "plus.magnifyingglass" : "minus.magnifyingglass")
                }
                
                Divider()
                
                Button {
                    audioService.seek(seconds: -1)
                } label: {
                    Image(systemName: "arrow.left")
                }

                Button {
                    if audioService.player.isPlaying {
                        audioService.player.pause()
                    } else {
                        audioService.player.play()
                    }
                } label: {
                    Image(systemName: audioService.player.isPlaying ? "pause.fill" : "play.fill")
                }

                Button {
                    audioService.seek(seconds: 1)
                } label: {
                    Image(systemName: "arrow.right")
                }
            }
            .frame(height: 20)

            TextEditor(text: $audioService.text)
                .font(.title2)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
