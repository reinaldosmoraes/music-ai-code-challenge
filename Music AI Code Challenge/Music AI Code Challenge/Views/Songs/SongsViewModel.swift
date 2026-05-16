//
//  SongsViewModel.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

// MARK: - Row model

struct SongListItem: Identifiable {
    let id: String
    let cardViewModel: SongCardViewModel
}

// MARK: - Presentation contract

protocol SongsViewModeling: AnyObject {
    var searchText: String { get set }
    var songItems: [SongListItem] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var showsEmptyState: Bool { get }

    var isSearchPromptVisible: Bool { get }

    func search() async
    func handleMenuTap(for songID: String)
}

// MARK: - Search configuration

private enum SearchConfiguration {
    static let minimumCharacterCount = 2
    static let debounceDuration: Duration = .seconds(1)
}

// MARK: - ViewModel

@MainActor
@Observable
final class SongsViewModel: SongsViewModeling {
    var searchText = ""
    private(set) var songItems: [SongListItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var hasLoadedOnce = false

    var showsEmptyState: Bool {
        hasLoadedOnce
            && !isLoading
            && errorMessage == nil
            && songItems.isEmpty
            && !isSearchPromptVisible
    }

    var isSearchPromptVisible: Bool {
        normalizedSearchQuery.count < SearchConfiguration.minimumCharacterCount
    }

    private let songsService: SongsFetching
    private var searchTask: Task<Void, Never>?

    private var normalizedSearchQuery: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    nonisolated init(songsService: SongsFetching = ITunesSongsService()) {
        self.songsService = songsService
    }

    func search() async {
        searchTask?.cancel()

        guard normalizedSearchQuery.count >= SearchConfiguration.minimumCharacterCount else {
            resetForInsufficientQuery()
            return
        }

        searchTask = Task { [weak self] in
            try? await Task.sleep(for: SearchConfiguration.debounceDuration)
            guard !Task.isCancelled else { return }
            await self?.performSearch()
        }
    }

    func handleMenuTap(for songID: String) {
        // Placeholder for future navigation to song options.
        _ = songID
    }

    private func resetForInsufficientQuery() {
        isLoading = false
        songItems = []
        errorMessage = nil
        hasLoadedOnce = true
    }

    private func performSearch() async {
        let query = normalizedSearchQuery
        errorMessage = nil
        hasLoadedOnce = true

        guard query.count >= SearchConfiguration.minimumCharacterCount else {
            resetForInsufficientQuery()
            return
        }

        isLoading = true

        defer {
            isLoading = false
        }

        do {
            let songs = try await songsService.searchSongs(query: query)
            guard !Task.isCancelled else { return }
            songItems = songs.map(makeListItem(from:))
        } catch is CancellationError {
            return
        } catch {
            songItems = []
            errorMessage = error.localizedDescription
        }
    }

    private func makeListItem(from song: Song) -> SongListItem {
        let songID = song.id
        return SongListItem(
            id: songID,
            cardViewModel: SongCardViewModel(
                model: song.toCardModel(),
                onMenuTapped: { [weak self] in
                    self?.handleMenuTap(for: songID)
                }
            )
        )
    }
}
