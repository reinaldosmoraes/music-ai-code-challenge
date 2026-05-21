//
//  MockAudioPlaying.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
@testable import Music_AI_Code_Challenge

@MainActor
final class MockAudioPlaying: AudioPlaying {
    var isPlaying = false
    var currentTime: TimeInterval = 0
    var duration: TimeInterval = 180
    var onPlaybackStateChange: (@MainActor (TimeInterval, TimeInterval, Bool) -> Void)?

    private(set) var prepareCallCount = 0
    private(set) var playCallCount = 0
    private(set) var pauseCallCount = 0
    private(set) var lastPreparedURL: URL?
    var prepareError: Error?

    func prepare(url: URL) async throws {
        prepareCallCount += 1
        lastPreparedURL = url

        if let prepareError {
            throw prepareError
        }
    }

    func play() {
        playCallCount += 1
        isPlaying = true
        notifyStateChange()
    }

    func pause() {
        pauseCallCount += 1
        isPlaying = false
        notifyStateChange()
    }

    func stop() {
        isPlaying = false
        currentTime = 0
        notifyStateChange()
    }

    func seek(to time: TimeInterval) {
        currentTime = time
        notifyStateChange()
    }

    func skip(by interval: TimeInterval) {
        currentTime = max(0, min(duration, currentTime + interval))
        notifyStateChange()
    }

    private func notifyStateChange() {
        onPlaybackStateChange?(currentTime, duration, isPlaying)
    }
}
