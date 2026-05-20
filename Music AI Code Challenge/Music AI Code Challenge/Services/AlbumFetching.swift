//
//  AlbumFetching.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

protocol AlbumFetching: Sendable {
    func fetchAlbum(
        collectionID: String,
        fallbackTitle: String,
        fallbackArtist: String,
        fallbackArtworkURL: URL?
    ) async throws -> AlbumDetail
}
