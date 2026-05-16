//
//  SongsFetching.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

protocol SongsFetching: Sendable {
    func searchSongs(query: String) async throws -> [Song]
}
