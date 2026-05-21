//
//  MockAlbumFetching.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
@testable import Music_AI_Code_Challenge

final class MockAlbumFetching: AlbumFetching, @unchecked Sendable {
    var albumDetail: AlbumDetail?
    var error: Error?
    private(set) var fetchCallCount = 0
    private(set) var lastCollectionID: String?

    func fetchAlbum(
        collectionID: String,
        fallbackTitle: String,
        fallbackArtist: String,
        fallbackArtworkURL: URL?
    ) async throws -> AlbumDetail {
        fetchCallCount += 1
        lastCollectionID = collectionID

        if let error {
            throw error
        }

        guard let albumDetail else {
            throw ITunesSearchError.decodingFailed
        }

        return albumDetail
    }
}
