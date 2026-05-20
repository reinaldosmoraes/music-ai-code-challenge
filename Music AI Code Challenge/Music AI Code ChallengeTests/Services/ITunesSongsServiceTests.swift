//
//  ITunesSongsServiceTests.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Testing
@testable import Music_AI_Code_Challenge

@Suite("ITunesSongsService")
struct ITunesSongsServiceTests {
    @Test func searchSongs_mapsAPIResults() async throws {
        let apiClient = MockITunesSearchAPIClient()
        apiClient.response = ITunesFixtures.makeSearchResponse(
            tracks: [ITunesFixtures.makeTrack()]
        )
        let service = ITunesSongsService(apiClient: apiClient)

        let songs = try await service.searchSongs(query: "prince")

        #expect(apiClient.searchCallCount == 1)
        #expect(apiClient.lastParameters?.term == "prince")
        #expect(songs.count == 1)
        #expect(songs.first?.title == "Purple Rain")
    }

    @Test func searchSongs_returnsEmptyForBlankQuery() async throws {
        let apiClient = MockITunesSearchAPIClient()
        let service = ITunesSongsService(apiClient: apiClient)

        let songs = try await service.searchSongs(query: "   ")

        #expect(songs.isEmpty)
        #expect(apiClient.searchCallCount == 0)
    }

    @Test func searchSongs_propagatesAPIError() async {
        let apiClient = MockITunesSearchAPIClient()
        apiClient.error = ITunesSearchError.invalidResponse
        let service = ITunesSongsService(apiClient: apiClient)

        await #expect(throws: ITunesSearchError.self) {
            _ = try await service.searchSongs(query: "love")
        }
    }
}
