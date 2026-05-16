//
//  MusicPlayerViewModel.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

// MARK: - Presentation contract

protocol MusicPlayerViewModeling {
    var currentTrackID: String { get }
    var title: String { get }
    var artist: String { get }
    var album: String? { get }
    var artworkURL: URL? { get }
    var isPlaying: Bool { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var formattedCurrentTime: String { get }
    var formattedRemainingTime: String { get }
    var playbackProgress: Double { get }
    var canPlayPrevious: Bool { get }
    var canPlayNext: Bool { get }

    func onAppear() async
    func update(with model: MusicPlayerModel) async
    func updatePlaylist(_ playlist: [MusicPlayerModel], currentTrackID: String)
    func playPreviousTrack() async
    func playNextTrack() async
    func togglePlayPause()
    func seek(to progress: Double)
    func viewAlbum()
}

// MARK: - ViewModel

@MainActor
@Observable
final class MusicPlayerViewModel: MusicPlayerViewModeling {
    private(set) var currentTrackID: String
    private(set) var title: String
    private(set) var artist: String
    private(set) var album: String?
    private(set) var artworkURL: URL?

    private(set) var isPlaying = false
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var currentTime: TimeInterval = 0
    private(set) var duration: TimeInterval = 0

    private(set) var canPlayPrevious = false
    private(set) var canPlayNext = false

    var formattedCurrentTime: String { Self.formatTime(currentTime) }

    var formattedRemainingTime: String {
        guard duration > 0 else { return "-0:00" }
        let remaining = max(0, duration - currentTime)
        return "-\(Self.formatTime(remaining))"
    }

    var playbackProgress: Double {
        guard duration > 0 else { return 0 }
        return min(max(currentTime / duration, 0), 1)
    }

    private var playlist: [MusicPlayerModel] = []
    private var currentIndex = 0
    private var previewURL: URL
    private let audioService: AudioPlaying
    private var hasPreparedPlayback = false
    private var isAudioServiceBound = false

    init(model: MusicPlayerModel, audioService: AudioPlaying = AVPlayerAudioService()) {
        currentTrackID = model.id
        title = model.title
        artist = model.artist
        album = model.album
        artworkURL = model.artworkURL
        previewURL = model.previewURL
        self.audioService = audioService
        playlist = [model]
        currentIndex = 0
        updateNavigationAvailability()
    }

    func onAppear() async {
        bindAudioServiceIfNeeded()
        guard !hasPreparedPlayback else { return }
        await startPlayback()
    }

    func update(with model: MusicPlayerModel) async {
        let isSameTrack = model.id == currentTrackID
        applyModel(model)
        updateCurrentIndex(for: model.id)
        guard !isSameTrack else { return }

        hasPreparedPlayback = false
        await startPlayback()
    }

    func updatePlaylist(_ playlist: [MusicPlayerModel], currentTrackID: String) {
        self.playlist = playlist
        updateCurrentIndex(for: currentTrackID)
    }

    func playPreviousTrack() async {
        guard canPlayPrevious, playlist.indices.contains(currentIndex - 1) else { return }
        currentIndex -= 1
        await update(with: playlist[currentIndex])
    }

    func playNextTrack() async {
        guard canPlayNext, playlist.indices.contains(currentIndex + 1) else { return }
        currentIndex += 1
        await update(with: playlist[currentIndex])
    }

    func togglePlayPause() {
        guard errorMessage == nil, hasPreparedPlayback else { return }

        if isPlaying {
            audioService.pause()
        } else {
            if currentTime >= duration, duration > 0 {
                audioService.seek(to: 0)
            }
            audioService.play()
        }
        syncPlaybackState()
    }

    func seek(to progress: Double) {
        guard hasPreparedPlayback, duration > 0 else { return }
        let clampedProgress = min(max(progress, 0), 1)
        audioService.seek(to: duration * clampedProgress)
        syncPlaybackState()
    }

    func viewAlbum() {
        // Placeholder for future album screen navigation.
    }

    private func applyModel(_ model: MusicPlayerModel) {
        currentTrackID = model.id
        title = model.title
        artist = model.artist
        album = model.album
        artworkURL = model.artworkURL
        previewURL = model.previewURL
        updateNavigationAvailability()
    }

    private func updateCurrentIndex(for trackID: String) {
        guard let index = playlist.firstIndex(where: { $0.id == trackID }) else {
            canPlayPrevious = false
            canPlayNext = false
            return
        }
        currentIndex = index
        updateNavigationAvailability()
    }

    private func updateNavigationAvailability() {
        canPlayPrevious = currentIndex > 0
        canPlayNext = !playlist.isEmpty && currentIndex < playlist.count - 1
    }

    private func startPlayback() async {
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            try await audioService.prepare(url: previewURL)
            hasPreparedPlayback = true
            syncPlaybackState()
            audioService.play()
            syncPlaybackState()
        } catch {
            errorMessage = error.localizedDescription
            hasPreparedPlayback = false
        }
    }

    private func bindAudioServiceIfNeeded() {
        guard !isAudioServiceBound else { return }
        audioService.onPlaybackStateChange = { [weak self] currentTime, duration, isPlaying in
            self?.currentTime = currentTime
            self?.duration = duration
            self?.isPlaying = isPlaying
        }
        isAudioServiceBound = true
    }

    private func syncPlaybackState() {
        currentTime = audioService.currentTime
        duration = audioService.duration
        isPlaying = audioService.isPlaying
    }

    private static func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite, time >= 0 else { return "0:00" }

        let totalSeconds = Int(time.rounded(.down))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
