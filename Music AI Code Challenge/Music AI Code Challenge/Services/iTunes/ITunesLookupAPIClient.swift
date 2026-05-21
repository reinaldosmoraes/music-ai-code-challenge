//
//  ITunesLookupAPIClient.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

protocol ITunesLookupAPIClient: Sendable {
    func lookupAlbum(collectionID: String, country: String) async throws -> ITunesLookupResponse
}

struct URLSessionITunesLookupAPIClient: ITunesLookupAPIClient {
    private static let baseURL = URL(string: "https://itunes.apple.com/lookup")!

    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func lookupAlbum(collectionID: String, country: String) async throws -> ITunesLookupResponse {
        guard var components = URLComponents(url: Self.baseURL, resolvingAgainstBaseURL: false) else {
            throw ITunesSearchError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "id", value: collectionID),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "country", value: country),
        ]

        guard let requestURL = components.url else {
            throw ITunesSearchError.invalidURL
        }

        let (data, response) = try await session.data(from: requestURL)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ITunesSearchError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw ITunesSearchError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(ITunesLookupResponse.self, from: data)
        } catch {
            throw ITunesSearchError.decodingFailed
        }
    }
}
