//
//  SongsViewModelTests.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
import SwiftUI
import Testing
@testable import Music_AI_Code_Challenge

@MainActor
@Suite("SongsViewModel")
struct SongsViewModelTests {
    private func makeViewModel(
        songsService: MockSongsFetching? = nil,
        recentlyPlayedStore: MockRecentlyPlayedStore? = nil
    ) -> SongsViewModel {
        SongsViewModel(
            songsService: songsService ?? MockSongsFetching(),
            recentlyPlayedStore: recentlyPlayedStore ?? MockRecentlyPlayedStore(),
            searchDebounceDuration: .zero
        )
    }

    @Test func showsSearchForSongsPrompt_whenNoRecentsAndShortQuery() {
        let viewModel = makeViewModel()

        viewModel.searchText = ""

        #expect(viewModel.showsSearchForSongsPrompt == true)
        #expect(viewModel.showsRecentlyPlayed == false)
    }

    @Test func loadRecentlyPlayed_populatesListFromStore() {
        let store = MockRecentlyPlayedStore()
        store.songs = [SongFixtures.makeSong(id: "recent-1")]
        let viewModel = makeViewModel(recentlyPlayedStore: store)

        viewModel.loadRecentlyPlayed()

        #expect(viewModel.recentlyPlayedItems.count == 1)
        #expect(viewModel.recentlyPlayedItems.first?.id == "recent-1")
    }

    @Test func search_populatesSongItemsFromService() async {
        let songsService = MockSongsFetching()
        songsService.songsToReturn = SongFixtures.makePlaylist(count: 2)
        let viewModel = makeViewModel(songsService: songsService)
        viewModel.searchText = "pr"

        await viewModel.search()
        await waitForSearchCompletion(viewModel)

        #expect(songsService.searchCallCount == 1)
        #expect(viewModel.songItems.count == 2)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func search_setsErrorMessageWhenServiceFails() async {
        let songsService = MockSongsFetching()
        songsService.error = ITunesSearchError.invalidResponse
        let viewModel = makeViewModel(songsService: songsService)
        viewModel.searchText = "rock"

        await viewModel.search()
        await waitForSearchCompletion(viewModel)

        #expect(viewModel.songItems.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }

    @Test func selectSong_recordsRecentlyPlayedAndShowsPlayer() {
        let store = MockRecentlyPlayedStore()
        let song = SongFixtures.makeSong(id: "play-1")
        let viewModel = makeViewModel(recentlyPlayedStore: store)
        viewModel.registerSongs([song])

        viewModel.selectSong(id: "play-1")

        #expect(store.recordCallCount == 1)
        #expect(viewModel.playerViewModel != nil)
        #expect(viewModel.playerPresentation == .expanded)
        #expect(viewModel.isPlayerVisible == true)
    }

    @Test func openCurrentAlbum_appendsRouteWhenCollectionAvailable() {
        let song = SongFixtures.makeSong(id: "album-track", collectionID: "album-99")
        let viewModel = makeViewModel()
        viewModel.registerSongs([song])
        viewModel.selectSong(id: song.id)
        viewModel.minimizePlayer()

        viewModel.openCurrentAlbum()

        #expect(viewModel.navigationPath.count == 1)
        #expect(viewModel.playerPresentation == .minimized)
    }

    @Test func minimizeAndExpandPlayer_updatesPresentation() {
        let song = SongFixtures.makeSong()
        let viewModel = makeViewModel()
        viewModel.registerSongs([song])
        viewModel.selectSong(id: song.id)

        viewModel.minimizePlayer()
        #expect(viewModel.playerPresentation == .minimized)
        #expect(viewModel.miniPlayerBottomInset == 88)

        viewModel.expandPlayer()
        #expect(viewModel.playerPresentation == .expanded)
    }

    private func waitForSearchCompletion(_ viewModel: SongsViewModel) async {
        for _ in 0 ..< 50 {
            if viewModel.hasLoadedOnce, !viewModel.isLoading {
                return
            }
            try? await Task.sleep(for: .milliseconds(20))
        }
    }
}
