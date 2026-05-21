//
//  MusicPlayerViewModelTests.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
import Testing
@testable import Music_AI_Code_Challenge

@MainActor
@Suite("MusicPlayerViewModel")
struct MusicPlayerViewModelTests {
    private func makePlaylist() -> [MusicPlayerModel] {
        SongFixtures.makePlaylist(count: 3).compactMap(MusicPlayerModel.init(song:))
    }

    @Test func canViewAlbum_reflectsCollectionID() throws {
        let model = try #require(MusicPlayerModel(song: SongFixtures.makeSong(collectionID: "99")))
        let audio = MockAudioPlaying()
        let viewModel = MusicPlayerViewModel(model: model, audioService: audio)

        #expect(viewModel.canViewAlbum == true)
    }

    @Test func updatePlaylist_enablesNextAndPreviousCorrectly() throws {
        let playlist = try #require(makePlaylist())
        let audio = MockAudioPlaying()
        let viewModel = MusicPlayerViewModel(model: playlist[0], audioService: audio)

        viewModel.updatePlaylist(playlist, currentTrackID: playlist[1].id)

        #expect(viewModel.canPlayPrevious == true)
        #expect(viewModel.canPlayNext == true)
    }

    @Test func onAppear_preparesAudioAndStartsPlayback() async throws {
        let model = try #require(MusicPlayerModel(song: SongFixtures.makeSong()))
        let audio = MockAudioPlaying()
        let viewModel = MusicPlayerViewModel(model: model, audioService: audio)

        await viewModel.onAppear()

        #expect(audio.prepareCallCount == 1)
        #expect(audio.playCallCount == 1)
        #expect(viewModel.isPlaying == true)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func playNextTrack_updatesCurrentTrack() async throws {
        let playlist = try #require(makePlaylist())
        let audio = MockAudioPlaying()
        let viewModel = MusicPlayerViewModel(model: playlist[0], audioService: audio)
        viewModel.updatePlaylist(playlist, currentTrackID: playlist[0].id)
        await viewModel.onAppear()

        await viewModel.playNextTrack()

        #expect(viewModel.currentTrackID == playlist[1].id)
        #expect(viewModel.title == playlist[1].title)
    }

    @Test func togglePlayPause_pausesAndResumesPlayback() async throws {
        let model = try #require(MusicPlayerModel(song: SongFixtures.makeSong()))
        let audio = MockAudioPlaying()
        let viewModel = MusicPlayerViewModel(model: model, audioService: audio)
        await viewModel.onAppear()

        viewModel.togglePlayPause()
        #expect(audio.pauseCallCount == 1)
        #expect(viewModel.isPlaying == false)

        viewModel.togglePlayPause()
        #expect(audio.playCallCount == 2)
        #expect(viewModel.isPlaying == true)
    }

    @Test func seek_updatesAudioServicePosition() async throws {
        let model = try #require(MusicPlayerModel(song: SongFixtures.makeSong()))
        let audio = MockAudioPlaying()
        audio.duration = 200
        let viewModel = MusicPlayerViewModel(model: model, audioService: audio)
        await viewModel.onAppear()

        viewModel.seek(to: 0.5)

        #expect(audio.currentTime == 100)
    }

    @Test func formattedRemainingTime_showsNegativeDuration() async throws {
        let model = try #require(MusicPlayerModel(song: SongFixtures.makeSong()))
        let audio = MockAudioPlaying()
        audio.duration = 125
        audio.currentTime = 25
        let viewModel = MusicPlayerViewModel(model: model, audioService: audio)
        await viewModel.onAppear()

        #expect(viewModel.formattedRemainingTime == "-1:40")
    }
}
