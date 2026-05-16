//
//  ITunesSongsService.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

struct ITunesSongsService: SongsFetching {
    private let apiClient: ITunesSearchAPIClient
    private let defaultParameters: ITunesSearchParameters

    init(
        apiClient: ITunesSearchAPIClient = URLSessionITunesSearchAPIClient(),
        country: String = ITunesSearchParameters.defaultCountry,
        limit: Int = ITunesSearchParameters.defaultLimit
    ) {
        self.apiClient = apiClient
        self.defaultParameters = ITunesSearchParameters(
            term: "",
            country: country,
            limit: limit
        )
    }

    func searchSongs(query: String) async throws -> [Song] {
        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else {
            return []
        }

        let parameters = ITunesSearchParameters(
            term: normalizedQuery,
            country: defaultParameters.country,
            media: defaultParameters.media,
            entity: defaultParameters.entity,
            limit: defaultParameters.limit
        )

        let response = try await apiClient.search(parameters: parameters)
        return response.results.compactMap(ITunesSongMapper.map)
    }
}
