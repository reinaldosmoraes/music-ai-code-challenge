//
//  Song.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

struct Song: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let artist: String
    let album: String?
    let collectionID: String?
    let artworkURL: URL?
    let previewURL: URL?
    let trackDuration: TimeInterval?

    init(
        id: String = UUID().uuidString,
        title: String,
        artist: String,
        album: String? = nil,
        collectionID: String? = nil,
        artworkURL: URL? = nil,
        previewURL: URL? = nil,
        trackDuration: TimeInterval? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.collectionID = collectionID
        self.artworkURL = artworkURL
        self.previewURL = previewURL
        self.trackDuration = trackDuration
    }

    var isPlayable: Bool {
        previewURL != nil
    }

    func toAlbumTrackCardModel() -> SongCardModel {
        SongCardModel(
            id: id,
            title: title,
            subtitle: artist,
            artworkURL: artworkURL
        )
    }

    func toCardModel() -> SongCardModel {
        let subtitle: String
        if let album, !album.isEmpty {
            subtitle = "\(artist) · \(album)"
        } else {
            subtitle = artist
        }

        return SongCardModel(
            id: id,
            title: title,
            subtitle: subtitle,
            artworkURL: artworkURL
        )
    }
}
