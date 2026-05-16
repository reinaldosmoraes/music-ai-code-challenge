//
//  Song.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

struct Song: Identifiable, Equatable, Sendable {
    let id: UUID
    let title: String
    let artist: String
    let album: String?
    let artworkAssetName: String?

    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        album: String? = nil,
        artworkAssetName: String? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.artworkAssetName = artworkAssetName
    }

    func toCardModel() -> SongCardModel {
        let subtitle: String
        if let album, !album.isEmpty {
            subtitle = "\(artist) · \(album)"
        } else {
            subtitle = artist
        }

        let artwork: SongCardArtwork
        if let artworkAssetName, !artworkAssetName.isEmpty {
            artwork = .asset(name: artworkAssetName)
        } else {
            artwork = .placeholder
        }

        return SongCardModel(
            id: id,
            title: title,
            subtitle: subtitle,
            artwork: artwork
        )
    }
}
