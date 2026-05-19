//
//  MusicPlayerModel.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

struct MusicPlayerModel: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let artist: String
    let album: String?
    let collectionID: String?
    let artworkURL: URL?
    let previewURL: URL

    var canViewAlbum: Bool {
        guard let collectionID else { return false }
        return !collectionID.isEmpty
    }

    init?(song: Song) {
        guard let previewURL = song.previewURL else { return nil }

        self.id = song.id
        self.title = song.title
        self.artist = song.artist
        self.album = song.album
        self.collectionID = song.collectionID
        self.artworkURL = song.artworkURL
        self.previewURL = previewURL
    }
}
