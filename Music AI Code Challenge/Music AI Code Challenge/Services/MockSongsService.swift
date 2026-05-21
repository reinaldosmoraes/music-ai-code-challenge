//
//  MockSongsService.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

struct MockSongsService: SongsFetching {
    private static let mockPreviewURL = URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")

    private static let catalog: [Song] = [
        Song(title: "Purple Rain", artist: "Prince", album: "Purple Rain", previewURL: mockPreviewURL),
        Song(title: "Bohemian Rhapsody", artist: "Queen", album: "A Night at the Opera", previewURL: mockPreviewURL),
        Song(title: "Billie Jean", artist: "Michael Jackson", album: "Thriller", previewURL: mockPreviewURL),
        Song(title: "Like a Rolling Stone", artist: "Bob Dylan", album: "Highway 61 Revisited", previewURL: mockPreviewURL),
        Song(title: "Smells Like Teen Spirit", artist: "Nirvana", album: "Nevermind", previewURL: mockPreviewURL),
        Song(title: "What's Going On", artist: "Marvin Gaye", album: "What's Going On", previewURL: mockPreviewURL),
        Song(title: "Respect", artist: "Aretha Franklin", album: "I Never Loved a Man the Way I Love You", previewURL: mockPreviewURL),
        Song(title: "Imagine", artist: "John Lennon", album: "Imagine", previewURL: mockPreviewURL),
        Song(title: "Hey Jude", artist: "The Beatles", album: "Hey Jude", previewURL: mockPreviewURL),
        Song(title: "Midnight City", artist: "M83", album: "Hurry Up, We're Dreaming", previewURL: mockPreviewURL),
        Song(title: "Blinding Lights", artist: "The Weeknd", album: "After Hours", previewURL: mockPreviewURL),
        Song(title: "HUMBLE.", artist: "Kendrick Lamar", album: "DAMN.", previewURL: mockPreviewURL),
        Song(title: "Bad Guy", artist: "Billie Eilish", album: "When We All Fall Asleep, Where Do We Go?", previewURL: mockPreviewURL),
        Song(title: "Shape of You", artist: "Ed Sheeran", album: "÷", previewURL: mockPreviewURL),
        Song(title: "Rolling in the Deep", artist: "Adele", album: "21", previewURL: mockPreviewURL),
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
