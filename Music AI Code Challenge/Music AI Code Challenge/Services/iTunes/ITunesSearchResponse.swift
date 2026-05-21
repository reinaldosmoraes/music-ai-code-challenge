//
//  ITunesSearchResponse.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

struct ITunesSearchResponse: Decodable, Sendable {
    let resultCount: Int
    let results: [ITunesTrackDTO]
}

struct ITunesTrackDTO: Decodable, Sendable {
    let trackId: Int?
    let trackName: String?
    let artistName: String?
    let collectionId: Int?
    let collectionName: String?
    let artworkUrl100: String?
    let previewUrl: String?
    let trackTimeMillis: Int?
    let trackNumber: Int?
}

struct ITunesLookupResponse: Decodable, Sendable {
    let resultCount: Int
    let results: [ITunesLookupResultDTO]
}

struct ITunesLookupResultDTO: Decodable, Sendable {
    let wrapperType: String?
    let collectionId: Int?
    let collectionName: String?
    let artistName: String?
    let artworkUrl100: String?
    let trackId: Int?
    let trackName: String?
    let previewUrl: String?
    let trackTimeMillis: Int?
    let trackNumber: Int?
}
