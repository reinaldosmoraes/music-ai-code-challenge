//
//  MockSongsService.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

struct MockSongsService: SongsFetching {
    private static let catalog: [Song] = [
        Song(title: "Purple Rain", artist: "Prince", album: "Purple Rain"),
        Song(title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera"),
        Song(title: "Billie Jean", artist: "Michael Jackson", album: "Thriller"),
        Song(title: "Like a Rolling Stone", artist: "Bob Dylan", album: "Highway 61 Revisited"),
        Song(title: "Smells Like Teen Spirit", artist: "Nirvana", album: "Nevermind"),
        Song(title: "What's Going On", artist: "Marvin Gaye", album: "What's Going On"),
        Song(title: "Respect", artist: "Aretha Franklin", album: "I Never Loved a Man the Way I Love You"),
        Song(title: "Imagine", artist: "John Lennon", album: "Imagine"),
        Song(title: "Hey Jude", artist: "The Beatles", album: "Hey Jude"),
        Song(title: "Midnight City", artist: "M83", album: "Hurry Up, We're Dreaming"),
        Song(title: "Blinding Lights", artist: "The Weeknd", album: "After Hours"),
        Song(title: "HUMBLE.", artist: "Kendrick Lamar", album: "DAMN."),
        Song(title: "Bad Guy", artist: "Billie Eilish", album: "When We All Fall Asleep, Where Do We Go?"),
        Song(title: "Shape of You", artist: "Ed Sheeran", album: "÷"),
        Song(title: "Rolling in the Deep", artist: "Adele", album: "21"),
    ]

    private let simulatedLatency: Duration

    init(simulatedLatency: Duration = .milliseconds(350)) {
        self.simulatedLatency = simulatedLatency
    }

    func searchSongs(query: String) async throws -> [Song] {
        try await Task.sleep(for: simulatedLatency)

        let normalizedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else {
            return Self.catalog
        }

        return Self.catalog.filter { song in
            song.title.localizedCaseInsensitiveContains(normalizedQuery)
                || song.artist.localizedCaseInsensitiveContains(normalizedQuery)
                || (song.album?.localizedCaseInsensitiveContains(normalizedQuery) ?? false)
        }
    }
}
