//
//  RecentlyPlayedSong.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
import SwiftData

@Model
final class RecentlyPlayedSong {
    @Attribute(.unique) var id: String
    var title: String
    var artist: String
    var album: String?
    var collectionID: String?
    var artworkURLString: String?
    var previewURLString: String?
    var trackDuration: TimeInterval?
    var playedAt: Date

    init(song: Song, playedAt: Date = .now) {
        id = song.id
        title = song.title
        artist = song.artist
        album = song.album
        collectionID = song.collectionID
        artworkURLString = song.artworkURL?.absoluteString
        previewURLString = song.previewURL?.absoluteString
        trackDuration = song.trackDuration
        self.playedAt = playedAt
    }

    func update(from song: Song, playedAt: Date) {
        title = song.title
        artist = song.artist
        album = song.album
        collectionID = song.collectionID
        artworkURLString = song.artworkURL?.absoluteString
        previewURLString = song.previewURL?.absoluteString
        trackDuration = song.trackDuration
        self.playedAt = playedAt
    }

    func toSong() -> Song {
        Song(
            id: id,
            title: title,
            artist: artist,
            album: album,
            collectionID: collectionID,
            artworkURL: artworkURLString.flatMap(URL.init(string:)),
            previewURL: previewURLString.flatMap(URL.init(string:)),
            trackDuration: trackDuration
        )
    }
}
