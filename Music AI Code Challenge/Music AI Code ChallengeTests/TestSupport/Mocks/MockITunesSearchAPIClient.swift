//
//  MockITunesSearchAPIClient.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
@testable import Music_AI_Code_Challenge

final class MockITunesSearchAPIClient: ITunesSearchAPIClient, @unchecked Sendable {
    var response: ITunesSearchResponse = ITunesFixtures.makeSearchResponse(tracks: [])
    var error: Error?
    private(set) var searchCallCount = 0
    private(set) var lastParameters: ITunesSearchParameters?

    func search(parameters: ITunesSearchParameters) async throws -> ITunesSearchResponse {
        searchCallCount += 1
        lastParameters = parameters

        if let error {
            throw error
        }
        return response
    }
}
