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
    let collectionName: String?
    let artworkUrl100: String?
}
