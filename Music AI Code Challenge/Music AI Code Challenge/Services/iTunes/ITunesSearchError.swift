//
//  ITunesSearchError.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

enum ITunesSearchError: LocalizedError, Sendable {
    case emptySearchTerm
    case invalidURL
    case invalidResponse
    case httpStatus(Int)
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .emptySearchTerm:
            return LocalizedString.itunesErrorEmptySearchTerm
        case .invalidURL:
            return LocalizedString.itunesErrorInvalidURL
        case .invalidResponse:
            return LocalizedString.itunesErrorInvalidResponse
        case .httpStatus(let statusCode):
            return LocalizedString.itunesErrorHTTPStatus(statusCode)
        case .decodingFailed:
            return LocalizedString.itunesErrorDecodingFailed
        }
    }
}
