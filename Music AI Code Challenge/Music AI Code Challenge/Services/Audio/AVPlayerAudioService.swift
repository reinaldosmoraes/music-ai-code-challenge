//
//  AVPlayerAudioService.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import AVFoundation
import Foundation

enum AudioPlaybackError: LocalizedError, Sendable {
    case failedToConfigureSession
    case failedToLoadAsset

    var errorDescription: String? {
        switch self {
        case .failedToConfigureSession:
            return "Unable to configure audio playback."
        case .failedToLoadAsset:
            return "Unable to load the song preview."
        }
    }
}

@MainActor
final class AVPlayerAudioService: AudioPlaying {
    nonisolated init() {}

    private(set) var isPlaying = false
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0

    var onPlaybackStateChange: (@MainActor (TimeInterval, TimeInterval, Bool) -> Void)?

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?

    func prepare(url: URL) async throws {
        stop()
        try configureAudioSession()

        let item = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: item)

        let isReady = await waitUntilReadyToPlay(item)
        guard isReady else {
            throw AudioPlaybackError.failedToLoadAsset
        }

        let loadedDuration = try await item.asset.load(.duration).seconds
        duration = loadedDuration.isFinite && loadedDuration > 0 ? loadedDuration : 30
        currentTime = 0

        addObservers(for: item)
        notifyPlaybackStateChange()
    }

    func play() {
        player?.play()
        isPlaying = true
        notifyPlaybackStateChange()
    }

    func pause() {
        player?.pause()
        isPlaying = false
        notifyPlaybackStateChange()
    }

    func stop() {
        removeObservers()
        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        notifyPlaybackStateChange()
    }

    func seek(to time: TimeInterval) {
        let clampedTime = max(0, min(time, duration))
        player?.seek(
            to: CMTime(seconds: clampedTime, preferredTimescale: 600),
            toleranceBefore: .zero,
            toleranceAfter: .zero
        )
        currentTime = clampedTime
        notifyPlaybackStateChange()
    }

    func skip(by interval: TimeInterval) {
        seek(to: currentTime + interval)
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            throw AudioPlaybackError.failedToConfigureSession
        }
    }

    private func waitUntilReadyToPlay(_ item: AVPlayerItem) async -> Bool {
        for _ in 0 ..< 30 {
            if item.status == .readyToPlay {
                return true
            }
            if item.status == .failed {
                return false
            }
            try? await Task.sleep(for: .milliseconds(100))
        }
        return item.status == .readyToPlay
    }

    private func addObservers(for item: AVPlayerItem) {
        let interval = CMTime(seconds: 0.5, preferredTimescale: 600)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self else { return }
            self.currentTime = time.seconds
            self.notifyPlaybackStateChange()
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.isPlaying = false
            self.currentTime = self.duration
            self.notifyPlaybackStateChange()
        }
    }

    private func removeObservers() {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
        }
        timeObserver = nil

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil
    }

    private func notifyPlaybackStateChange() {
        onPlaybackStateChange?(currentTime, duration, isPlaying)
    }
}
