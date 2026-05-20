//
//  AlbumViewModel.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

// MARK: - Presentation contract

protocol AlbumViewModeling {
    var title: String { get }
    var artist: String { get }
    var artworkURL: URL? { get }
    var songItems: [SongListItem] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }

    func onAppear() async
    func selectSong(id: String)
}

// MARK: - ViewModel

@MainActor
@Observable
final class AlbumViewModel: AlbumViewModeling {
    private(set) var title: String
    private(set) var artist: String
    private(set) var artworkURL: URL?
    private(set) var songItems: [SongListItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let collectionID: String
    private let albumService: AlbumFetching
    private let onSelectSong: (Song) -> Void
    private let onSongsLoaded: ([Song]) -> Void
    private var hasLoaded = false

    init(
        route: AlbumRoute,
        albumService: AlbumFetching = ITunesAlbumService(),
        onSelectSong: @escaping (Song) -> Void,
        onSongsLoaded: @escaping ([Song]) -> Void
    ) {
        collectionID = route.collectionID
        title = route.fallbackTitle
        artist = route.fallbackArtist
        artworkURL = route.fallbackArtworkURL
        self.albumService = albumService
        self.onSelectSong = onSelectSong
        self.onSongsLoaded = onSongsLoaded
    }

    func onAppear() async {
        guard !hasLoaded else { return }
        await loadAlbum()
    }

    func selectSong(id: String) {
        guard let song = songItems.first(where: { $0.id == id })?.song else { return }
        onSelectSong(song)
    }

    private func loadAlbum() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
            hasLoaded = true
        }

        do {
            let albumDetail = try await albumService.fetchAlbum(
                collectionID: collectionID,
                fallbackTitle: title,
                fallbackArtist: artist,
                fallbackArtworkURL: artworkURL
            )

            title = albumDetail.album.title
            artist = albumDetail.album.artist
            artworkURL = albumDetail.album.artworkURL
            songItems = albumDetail.songs.map(makeListItem(from:))
            onSongsLoaded(albumDetail.songs)
        } catch {
            errorMessage = error.localizedDescription
            songItems = []
        }
    }

    private func makeListItem(from song: Song) -> SongListItem {
        SongListItem(
            id: song.id,
            song: song,
            cardViewModel: SongCardViewModel(
                model: song.toAlbumTrackCardModel(),
                onMenuTapped: nil
            )
        )
    }
}
