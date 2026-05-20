//
//  ITunesSongMapperTests.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
import Testing
@testable import Music_AI_Code_Challenge

@Suite("ITunesSongMapper")
struct ITunesSongMapperTests {
    @Test func map_buildsSongFromValidTrack() {
        let track = ITunesFixtures.makeTrack()

        let song = ITunesSongMapper.map(track)

        #expect(song?.id == "1")
        #expect(song?.title == "Purple Rain")
        #expect(song?.artist == "Prince")
        #expect(song?.collectionID == "1440813271")
        #expect(song?.previewURL?.absoluteString == "https://example.com/preview.mp3")
    }

    @Test func map_returnsNilWhenRequiredFieldsMissing() {
        let track = ITunesFixtures.makeTrack(trackId: nil, trackName: "Title", artistName: "Artist")

        #expect(ITunesSongMapper.map(track) == nil)
    }

    @Test func higherResolutionArtworkURL_upgradesThumbnailSize() {
        let url = URL(string: "https://example.com/100x100bb.jpg")!

        let upgraded = ITunesSongMapper.higherResolutionArtworkURL(from: url)

        #expect(upgraded.absoluteString.contains("200x200bb"))
    }

    @Test func mapLookupTrack_sortsAlbumNameFromParameter() {
        let result = ITunesFixtures.makeLookupResult(
            wrapperType: "track",
            artistName: "Prince",
            trackId: 99,
            trackName: "When Doves Cry",
            previewUrl: "https://example.com/preview.mp3"
        )

        let song = ITunesSongMapper.mapLookupTrack(result, albumName: "Purple Rain")

        #expect(song?.album == "Purple Rain")
        #expect(song?.id == "99")
    }
}
