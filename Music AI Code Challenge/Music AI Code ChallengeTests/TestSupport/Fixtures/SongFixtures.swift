//
//  SongFixtures.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
@testable import Music_AI_Code_Challenge

enum SongFixtures {
    static let previewURL = URL(string: "https://example.com/preview.mp3")!
    static let artworkURL = URL(string: "https://example.com/artwork/100x100bb.jpg")!

    static func makeSong(
        id: String = "track-1",
        title: String = "Purple Rain",
        artist: String = "Prince",
        album: String? = "Purple Rain",
        collectionID: String? = "1440813271",
        artworkURL: URL? = artworkURL,
        previewURL: URL? = previewURL,
        trackDuration: TimeInterval? = 240
    ) -> Song {
        Song(
            id: id,
            title: title,
            artist: artist,
            album: album,
            collectionID: collectionID,
            artworkURL: artworkURL,
            previewURL: previewURL,
            trackDuration: trackDuration
        )
    }

    static func makePlaylist(count: Int = 3) -> [Song] {
        (1 ... count).map { index in
            makeSong(
                id: "track-\(index)",
                title: "Song \(index)",
                artist: "Artist \(index)",
                album: "Album \(index)",
                collectionID: "album-\(index)"
            )
        }
    }

    static var songWithoutPreview: Song {
        makeSong(id: "no-preview", previewURL: nil)
    }
}
