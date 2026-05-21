//
//  AlbumViewModelTests.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Testing
@testable import Music_AI_Code_Challenge

@MainActor
@Suite("AlbumViewModel")
struct AlbumViewModelTests {
    private func makeViewModel(
        albumService: MockAlbumFetching = MockAlbumFetching(),
        onSelectSong: @escaping (Song) -> Void = { _ in },
        onSongsLoaded: @escaping ([Song]) -> Void = { _ in }
    ) -> AlbumViewModel {
        AlbumViewModel(
            route: AlbumRoute(
                collectionID: "1440813271",
                fallbackTitle: "Fallback Album",
                fallbackArtist: "Fallback Artist"
            ),
            albumService: albumService,
            onSelectSong: onSelectSong,
            onSongsLoaded: onSongsLoaded
        )
    }

    @Test func onAppear_loadsAlbumDetailFromService() async {
        let albumService = MockAlbumFetching()
        albumService.albumDetail = AlbumDetail(
            album: Album(id: "1440813271", title: "Purple Rain", artist: "Prince", artworkURL: nil),
            songs: SongFixtures.makePlaylist(count: 2)
        )
        let viewModel = makeViewModel(albumService: albumService)

        await viewModel.onAppear()

        #expect(albumService.fetchCallCount == 1)
        #expect(viewModel.title == "Purple Rain")
        #expect(viewModel.artist == "Prince")
        #expect(viewModel.songItems.count == 2)
        #expect(viewModel.errorMessage == nil)
    }

    @Test func onAppear_setsErrorWhenServiceFails() async {
        let albumService = MockAlbumFetching()
        albumService.error = ITunesSearchError.decodingFailed
        let viewModel = makeViewModel(albumService: albumService)

        await viewModel.onAppear()

        #expect(viewModel.songItems.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }

    @Test func onAppear_loadsOnlyOnce() async {
        let albumService = MockAlbumFetching()
        albumService.albumDetail = AlbumDetail(
            album: Album(id: "1", title: "Album", artist: "Artist", artworkURL: nil),
            songs: [SongFixtures.makeSong()]
        )
        let viewModel = makeViewModel(albumService: albumService)

        await viewModel.onAppear()
        await viewModel.onAppear()

        #expect(albumService.fetchCallCount == 1)
    }

    @Test func selectSong_invokesCallbackWithMatchingSong() async {
        let albumService = MockAlbumFetching()
        let expectedSong = SongFixtures.makeSong(id: "album-track")
        albumService.albumDetail = AlbumDetail(
            album: Album(id: "1", title: "Album", artist: "Artist", artworkURL: nil),
            songs: [expectedSong]
        )

        var selectedSong: Song?
        let viewModel = makeViewModel(
            albumService: albumService,
            onSelectSong: { selectedSong = $0 }
        )

        await viewModel.onAppear()
        viewModel.selectSong(id: "album-track")

        #expect(selectedSong?.id == expectedSong.id)
    }

    @Test func onAppear_notifiesSongsLoaded() async {
        let albumService = MockAlbumFetching()
        let songs = SongFixtures.makePlaylist(count: 2)
        albumService.albumDetail = AlbumDetail(
            album: Album(id: "1", title: "Album", artist: "Artist", artworkURL: nil),
            songs: songs
        )

        var loadedSongs: [Song] = []
        let viewModel = makeViewModel(
            albumService: albumService,
            onSongsLoaded: { loadedSongs = $0 }
        )

        await viewModel.onAppear()

        #expect(loadedSongs.count == 2)
    }
}
