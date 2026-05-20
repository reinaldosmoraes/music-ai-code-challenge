//
//  FileRecentlyPlayedStore.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation

/// Persists the last played songs as JSON in the app’s Application Support directory.
final class FileRecentlyPlayedStore: RecentlyPlayedStoring, @unchecked Sendable {
    private enum Configuration {
        static let maxStoredCount = 10
        static let fileName = "recently_played.json"
    }

    private let fileURL: URL
    private let fileManager: FileManager
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let appDirectory = directory.appendingPathComponent(
            Bundle.main.bundleIdentifier ?? "MusicAICodeChallenge",
            isDirectory: true
        )

        if !fileManager.fileExists(atPath: appDirectory.path) {
            try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }

        fileURL = appDirectory.appendingPathComponent(Configuration.fileName)
    }

    func fetchAll() -> [Song] {
        guard fileManager.fileExists(atPath: fileURL.path),
              let data = try? Data(contentsOf: fileURL),
              let songs = try? decoder.decode([Song].self, from: data) else {
            return []
        }
        return songs
    }

    func record(_ song: Song) {
        var songs = fetchAll()
        songs.removeAll { $0.id == song.id }
        songs.insert(song, at: 0)

        if songs.count > Configuration.maxStoredCount {
            songs = Array(songs.prefix(Configuration.maxStoredCount))
        }

        guard let data = try? encoder.encode(songs) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
