//
//  MockSongsFetching.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
@testable import Music_AI_Code_Challenge

/// Configurable test double for `SongsFetching` (Dependency Inversion).
final class MockSongsFetching: SongsFetching, @unchecked Sendable {
    var songsToReturn: [Song] = []
    var error: Error?
    private(set) var searchCallCount = 0
    private(set) var lastQuery: String?

    func searchSongs(query: String) async throws -> [Song] {
        searchCallCount += 1
        lastQuery = query

        if let error {
            throw error
        }
        return songsToReturn
    }
}
