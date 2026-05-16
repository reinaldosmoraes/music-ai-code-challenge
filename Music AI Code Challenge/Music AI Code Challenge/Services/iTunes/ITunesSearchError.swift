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
            return "Enter a search term to find songs."
        case .invalidURL:
            return "Unable to build the iTunes search request."
        case .invalidResponse:
            return "The iTunes service returned an unexpected response."
        case .httpStatus(let statusCode):
            return "The iTunes service returned status code \(statusCode)."
        case .decodingFailed:
            return "Unable to read the iTunes search results."
        }
    }
}
