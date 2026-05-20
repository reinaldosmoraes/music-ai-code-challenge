//
//  MockSongsServiceTests.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Testing
@testable import Music_AI_Code_Challenge

@Suite("MockSongsService")
struct MockSongsServiceTests {
    @Test func searchSongs_filtersCatalogByQuery() async throws {
        let service = MockSongsService(simulatedLatency: .zero)

        let songs = try await service.searchSongs(query: "prince")

        #expect(songs.count == 1)
        #expect(songs.first?.title == "Purple Rain")
    }

    @Test func searchSongs_returnsFullCatalogForEmptyQuery() async throws {
        let service = MockSongsService(simulatedLatency: .zero)

        let songs = try await service.searchSongs(query: "")

        #expect(songs.count == 15)
    }
}
