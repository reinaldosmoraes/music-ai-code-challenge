//
//  SongsViewModel.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

// MARK: - Row model

struct SongListItem: Identifiable {
    let id: UUID
    let cardViewModel: SongCardViewModel
}

// MARK: - Presentation contract

protocol SongsViewModeling: AnyObject {
    var searchText: String { get set }
    var songItems: [SongListItem] { get }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var showsEmptyState: Bool { get }

    func search() async
    func handleMenuTap(for songID: UUID)
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
        hasLoadedOnce && !isLoading && errorMessage == nil && songItems.isEmpty
    }

    private let songsService: SongsFetching
    private var searchTask: Task<Void, Never>?

    nonisolated init(songsService: SongsFetching = MockSongsService()) {
        self.songsService = songsService
    }

    func search() async {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            await self?.performSearch()
        }
    }

    func handleMenuTap(for songID: UUID) {
        // Placeholder for future navigation to song options.
        _ = songID
    }

    private func performSearch() async {
        isLoading = true
        errorMessage = nil

        defer {
            isLoading = false
            hasLoadedOnce = true
        }

        do {
            let songs = try await songsService.searchSongs(query: searchText)
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
