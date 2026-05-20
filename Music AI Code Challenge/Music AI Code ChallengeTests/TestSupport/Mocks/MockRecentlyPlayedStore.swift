//
//  MockRecentlyPlayedStore.swift
//  Music AI Code ChallengeTests
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
@testable import Music_AI_Code_Challenge

@MainActor
final class MockRecentlyPlayedStore: RecentlyPlayedStoring {
    var songs: [Song] = []
    private(set) var recordCallCount = 0

    func fetchAll() -> [Song] {
        songs
    }

    func record(_ song: Song) {
        recordCallCount += 1
        songs.removeAll { $0.id == song.id }
        songs.insert(song, at: 0)

        if songs.count > 10 {
            songs = Array(songs.prefix(10))
        }
    }
}
