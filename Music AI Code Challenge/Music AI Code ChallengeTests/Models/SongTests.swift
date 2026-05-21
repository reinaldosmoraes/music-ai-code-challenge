//
//  SongTests.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Testing
@testable import Music_AI_Code_Challenge

@Suite("Song")
struct SongTests {
    @Test func isPlayable_isTrueWhenPreviewURLExists() {
        let song = SongFixtures.makeSong()

        #expect(song.isPlayable == true)
    }

    @Test func isPlayable_isFalseWhenPreviewURLMissing() {
        #expect(SongFixtures.songWithoutPreview.isPlayable == false)
    }

    @Test func toCardModel_includesAlbumInSubtitleWhenAvailable() {
        let song = SongFixtures.makeSong(artist: "Prince", album: "Purple Rain")
        let model = song.toCardModel()

        #expect(model.subtitle == "Prince · Purple Rain")
    }

    @Test func toAlbumTrackCardModel_usesArtistOnlySubtitle() {
        let song = SongFixtures.makeSong(artist: "Prince", album: "Purple Rain")
        let model = song.toAlbumTrackCardModel()

        #expect(model.subtitle == "Prince")
    }
}
