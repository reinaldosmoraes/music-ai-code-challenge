//
//  SwiftDataRecentlyPlayedStore.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataRecentlyPlayedStore: RecentlyPlayedStoring {
    private enum Configuration {
        static let maxStoredCount = 10
    }

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() -> [Song] {
        var descriptor = FetchDescriptor<RecentlyPlayedSong>(
            sortBy: [SortDescriptor(\.playedAt, order: .reverse)]
        )
        descriptor.fetchLimit = Configuration.maxStoredCount

        guard let entities = try? context.fetch(descriptor) else {
            return []
        }
        return entities.map { $0.toSong() }
    }

    func record(_ song: Song) {
        let songID = song.id
        var descriptor = FetchDescriptor<RecentlyPlayedSong>(
            predicate: #Predicate { $0.id == songID }
        )
        descriptor.fetchLimit = 1

        if let existing = try? context.fetch(descriptor).first {
            existing.update(from: song, playedAt: .now)
        } else {
            context.insert(RecentlyPlayedSong(song: song))
        }

        try? context.save()
        trimToMaxCount()
    }

    private func trimToMaxCount() {
        var descriptor = FetchDescriptor<RecentlyPlayedSong>(
            sortBy: [SortDescriptor(\.playedAt, order: .reverse)]
        )

        guard let entities = try? context.fetch(descriptor),
              entities.count > Configuration.maxStoredCount else {
            return
        }

        for entity in entities.dropFirst(Configuration.maxStoredCount) {
            context.delete(entity)
        }

        try? context.save()
    }
}
