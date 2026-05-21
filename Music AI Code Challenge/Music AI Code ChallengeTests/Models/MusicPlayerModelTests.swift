//
//  MusicPlayerModelTests.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
import Testing
@testable import Music_AI_Code_Challenge

@Suite("MusicPlayerModel")
struct MusicPlayerModelTests {
    @Test func init_succeedsWhenSongHasPreviewURL() {
        let song = SongFixtures.makeSong()

        let model = MusicPlayerModel(song: song)

        #expect(model != nil)
        #expect(model?.id == song.id)
        #expect(model?.title == song.title)
        #expect(model?.artist == song.artist)
        #expect(model?.collectionID == song.collectionID)
    }

    @Test func init_returnsNilWhenPreviewURLMissing() {
        let model = MusicPlayerModel(song: SongFixtures.songWithoutPreview)

        #expect(model == nil)
    }

    @Test func canViewAlbum_isTrueWhenCollectionIDPresent() {
        let song = SongFixtures.makeSong(collectionID: "1440813271")
        let model = MusicPlayerModel(song: song)

        #expect(model?.canViewAlbum == true)
    }

    @Test func canViewAlbum_isFalseWhenCollectionIDMissing() {
        let song = SongFixtures.makeSong(collectionID: nil)
        let model = MusicPlayerModel(song: song)

        #expect(model?.canViewAlbum == false)
    }
}
