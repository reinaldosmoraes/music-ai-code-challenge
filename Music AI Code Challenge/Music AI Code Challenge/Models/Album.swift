//
//  Album.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

struct Album: Equatable, Sendable {
    let id: String
    let title: String
    let artist: String
    let artworkURL: URL?
}

struct AlbumDetail: Equatable, Sendable {
    let album: Album
    let songs: [Song]
}

struct AlbumRoute: Hashable, Sendable {
    let collectionID: String
    let fallbackTitle: String
    let fallbackArtist: String
    let fallbackArtworkURL: URL?

    init(
        collectionID: String,
        fallbackTitle: String,
        fallbackArtist: String,
        fallbackArtworkURL: URL? = nil
    ) {
        self.collectionID = collectionID
        self.fallbackTitle = fallbackTitle
        self.fallbackArtist = fallbackArtist
        self.fallbackArtworkURL = fallbackArtworkURL
    }
}
