//
//  ITunesSearchParameters.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

/// Query parameters for the [iTunes Search API](https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI/Searching.html).
struct ITunesSearchParameters: Sendable, Equatable {
    let term: String
    let country: String
    let media: String
    let entity: String
    let limit: Int

    static let defaultCountry = "US"
    static let defaultMedia = "music"
    static let defaultEntity = "song"
    static let defaultLimit = 50

    init(
        term: String,
        country: String = Self.defaultCountry,
        media: String = Self.defaultMedia,
        entity: String = Self.defaultEntity,
        limit: Int = Self.defaultLimit
    ) {
        self.term = term
        self.country = country
        self.media = media
        self.entity = entity
        self.limit = limit
    }
}
