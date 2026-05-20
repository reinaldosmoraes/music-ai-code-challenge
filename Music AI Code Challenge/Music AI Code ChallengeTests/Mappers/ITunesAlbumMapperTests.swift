//
//  ITunesAlbumMapperTests.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Testing
@testable import Music_AI_Code_Challenge

@Suite("ITunesAlbumMapper")
struct ITunesAlbumMapperTests {
    @Test func map_buildsAlbumDetailFromLookupResponse() {
        let response = ITunesFixtures.makeAlbumLookupResponse(collectionID: "1440813271")

        let detail = ITunesAlbumMapper.map(
            response,
            collectionID: "1440813271",
            fallbackTitle: "Fallback Title",
            fallbackArtist: "Fallback Artist",
            fallbackArtworkURL: nil
        )

        #expect(detail != nil)
        #expect(detail?.album.title == "Purple Rain")
        #expect(detail?.album.artist == "Prince")
        #expect(detail?.songs.count == 2)
        #expect(detail?.songs.first?.title == "Track One")
        #expect(detail?.songs.last?.title == "Track Two")
    }

    @Test func map_usesFallbackMetadataWhenCollectionMissing() {
        let trackOnly = ITunesLookupResponse(
            resultCount: 1,
            results: [
                ITunesFixtures.makeLookupResult(
                    wrapperType: "track",
                    collectionId: 99,
                    artistName: "Artist",
                    trackId: 1,
                    trackName: "Song",
                    previewUrl: "https://example.com/preview.mp3",
                    trackNumber: 1
                ),
            ]
        )

        let detail = ITunesAlbumMapper.map(
            trackOnly,
            collectionID: "99",
            fallbackTitle: "Fallback",
            fallbackArtist: "Fallback Artist",
            fallbackArtworkURL: nil
        )

        #expect(detail?.album.title == "Fallback")
        #expect(detail?.album.artist == "Fallback Artist")
    }

    @Test func map_returnsNilWhenNoTracks() {
        let response = ITunesLookupResponse(
            resultCount: 1,
            results: [
                ITunesFixtures.makeLookupResult(
                    wrapperType: "collection",
                    collectionId: 1,
                    collectionName: "Empty Album",
                    artistName: "Artist"
                ),
            ]
        )

        let detail = ITunesAlbumMapper.map(
            response,
            collectionID: "1",
            fallbackTitle: "Fallback",
            fallbackArtist: "Fallback",
            fallbackArtworkURL: nil
        )

        #expect(detail == nil)
    }
}
