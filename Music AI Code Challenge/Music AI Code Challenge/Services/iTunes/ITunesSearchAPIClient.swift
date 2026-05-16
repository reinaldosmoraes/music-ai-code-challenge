//
//  ITunesSearchAPIClient.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

protocol ITunesSearchAPIClient: Sendable {
    func search(parameters: ITunesSearchParameters) async throws -> ITunesSearchResponse
}

struct URLSessionITunesSearchAPIClient: ITunesSearchAPIClient {
    private static let baseURL = URL(string: "https://itunes.apple.com/search")!

    private let session: URLSession
    private let decoder: JSONDecoder

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func search(parameters: ITunesSearchParameters) async throws -> ITunesSearchResponse {
        let requestURL = try makeRequestURL(for: parameters)
        let (data, response) = try await session.data(from: requestURL)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ITunesSearchError.invalidResponse
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw ITunesSearchError.httpStatus(httpResponse.statusCode)
        }

        do {
            return try decoder.decode(ITunesSearchResponse.self, from: data)
        } catch {
            throw ITunesSearchError.decodingFailed
        }
    }

    private func makeRequestURL(for parameters: ITunesSearchParameters) throws -> URL {
        guard var components = URLComponents(
            url: Self.baseURL,
            resolvingAgainstBaseURL: false
        ) else {
            throw ITunesSearchError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "term", value: parameters.term),
            URLQueryItem(name: "country", value: parameters.country),
            URLQueryItem(name: "media", value: parameters.media),
            URLQueryItem(name: "entity", value: parameters.entity),
            URLQueryItem(name: "limit", value: String(parameters.limit)),
        ]

        guard let url = components.url else {
            throw ITunesSearchError.invalidURL
        }

        return url
    }
}
