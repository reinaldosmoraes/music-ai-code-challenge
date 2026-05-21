//
//  ITunesFixtures.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
@testable import Music_AI_Code_Challenge

enum ITunesFixtures {
    static func makeTrack(
        trackId: Int? = 1,
        trackName: String = "Purple Rain",
        artistName: String = "Prince",
        collectionId: Int? = 1440813271,
        collectionName: String? = "Purple Rain",
        artworkUrl100: String? = "https://example.com/artwork/100x100bb.jpg",
        previewUrl: String? = "https://example.com/preview.mp3",
        trackTimeMillis: Int? = 240_000,
        trackNumber: Int? = 1
    ) -> ITunesTrackDTO {
        ITunesTrackDTO(
            trackId: trackId,
            trackName: trackName,
            artistName: artistName,
            collectionId: collectionId,
            collectionName: collectionName,
            artworkUrl100: artworkUrl100,
            previewUrl: previewUrl,
            trackTimeMillis: trackTimeMillis,
            trackNumber: trackNumber
        )
    }

    static func makeSearchResponse(tracks: [ITunesTrackDTO]) -> ITunesSearchResponse {
        ITunesSearchResponse(resultCount: tracks.count, results: tracks)
    }

    static func makeLookupResult(
        wrapperType: String,
        collectionId: Int? = nil,
        collectionName: String? = nil,
        artistName: String? = nil,
        artworkUrl100: String? = nil,
        trackId: Int? = nil,
        trackName: String? = nil,
        previewUrl: String? = nil,
        trackTimeMillis: Int? = nil,
        trackNumber: Int? = nil
    ) -> ITunesLookupResultDTO {
        ITunesLookupResultDTO(
            wrapperType: wrapperType,
            collectionId: collectionId,
            collectionName: collectionName,
            artistName: artistName,
            artworkUrl100: artworkUrl100,
            trackId: trackId,
            trackName: trackName,
            previewUrl: previewUrl,
            trackTimeMillis: trackTimeMillis,
            trackNumber: trackNumber
        )
    }

    static func makeAlbumLookupResponse(collectionID: String) -> ITunesLookupResponse {
        let collection = makeLookupResult(
            wrapperType: "collection",
            collectionId: Int(collectionID),
            collectionName: "Purple Rain",
            artistName: "Prince",
            artworkUrl100: "https://example.com/artwork/100x100bb.jpg"
        )
        let tracks = [
            makeLookupResult(
                wrapperType: "track",
                collectionId: Int(collectionID),
                artistName: "Prince",
                trackId: 10,
                trackName: "Track One",
                previewUrl: "https://example.com/one.mp3",
                trackNumber: 1
            ),
            makeLookupResult(
                wrapperType: "track",
                collectionId: Int(collectionID),
                artistName: "Prince",
                trackId: 11,
                trackName: "Track Two",
                previewUrl: "https://example.com/two.mp3",
                trackNumber: 2
            ),
        ]
        return ITunesLookupResponse(resultCount: tracks.count + 1, results: [collection] + tracks)
    }
}
