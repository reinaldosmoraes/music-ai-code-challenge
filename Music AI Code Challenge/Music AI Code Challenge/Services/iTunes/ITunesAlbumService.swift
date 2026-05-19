//
//  ITunesAlbumService.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

struct ITunesAlbumService: AlbumFetching {
    private let apiClient: ITunesLookupAPIClient
    private let country: String

    init(
        apiClient: ITunesLookupAPIClient = URLSessionITunesLookupAPIClient(),
        country: String = ITunesSearchParameters.defaultCountry
    ) {
        self.apiClient = apiClient
        self.country = country
    }

    func fetchAlbum(
        collectionID: String,
        fallbackTitle: String,
        fallbackArtist: String,
        fallbackArtworkURL: URL?
    ) async throws -> AlbumDetail {
        let response = try await apiClient.lookupAlbum(collectionID: collectionID, country: country)

        guard let albumDetail = ITunesAlbumMapper.map(
            response,
            collectionID: collectionID,
            fallbackTitle: fallbackTitle,
            fallbackArtist: fallbackArtist,
            fallbackArtworkURL: fallbackArtworkURL
        ) else {
            throw ITunesSearchError.decodingFailed
        }

        return albumDetail
    }
}
