//
//  SongsViewModel.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation
import CoreGraphics

// MARK: - Row model

struct SongListItem: Identifiable {
    let id: String
    let song: Song
    let cardViewModel: SongCardViewModel
}

// MARK: - Presentation contract

protocol SongsViewModeling: AnyObject {
    var searchText: String { get set }
    var songItems: [SongListItem] { get }
    var playerViewModel: MusicPlayerViewModel? { get }
    var playerPresentation: MusicPlayerPresentation { get set }
    var isLoading: Bool { get }
    var errorMessage: String? { get }
    var showsEmptyState: Bool { get }
    var isSearchPromptVisible: Bool { get }
    var isPlayerVisible: Bool { get }
    var miniPlayerBottomInset: CGFloat { get }

    func search() async
    func selectSong(id: String)
    func minimizePlayer()
    func expandPlayer()
    func handleMenuTap(for songID: String)
}

// MARK: - Search configuration

private enum SearchConfiguration {
    static let minimumCharacterCount = 2
    static let debounceDuration: Duration = .seconds(1)
    static let miniPlayerHeight: CGFloat = 88
}

// MARK: - ViewModel

@MainActor
@Observable
final class SongsViewModel: SongsViewModeling {
    var searchText = ""
    var playerPresentation: MusicPlayerPresentation = .hidden
    private(set) var playerViewModel: MusicPlayerViewModel?
    private(set) var songItems: [SongListItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var hasLoadedOnce = false

    var isPlayerVisible: Bool {
        playerPresentation != .hidden && playerViewModel != nil
    }

    var miniPlayerBottomInset: CGFloat {
        playerPresentation == .minimized ? SearchConfiguration.miniPlayerHeight : 0
    }

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
    private var songsByID: [String: Song] = [:]

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

    func selectSong(id: String) {
        guard let song = songsByID[id],
              let playerModel = MusicPlayerModel(song: song) else {
            return
        }

        if let playerViewModel {
            Task {
                await playerViewModel.update(with: playerModel)
            }
        } else {
            playerViewModel = MusicPlayerViewModel(model: playerModel)
            playerPresentation = .expanded
        }
    }

    func minimizePlayer() {
        guard playerPresentation == .expanded else { return }
        playerPresentation = .minimized
    }

    func expandPlayer() {
        guard playerPresentation == .minimized else { return }
        playerPresentation = .expanded
    }

    func handleMenuTap(for songID: String) {
        // Placeholder for future navigation to song options.
        _ = songID
    }

    private func resetForInsufficientQuery() {
        isLoading = false
        songItems = []
        songsByID = [:]
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
            songsByID = Dictionary(uniqueKeysWithValues: songs.map { ($0.id, $0) })
            songItems = songs.map(makeListItem(from:))
        } catch is CancellationError {
            return
        } catch {
            songsByID = [:]
            songItems = []
            errorMessage = error.localizedDescription
        }
    }

    private func makeListItem(from song: Song) -> SongListItem {
        let songID = song.id
        return SongListItem(
            id: songID,
            song: song,
            cardViewModel: SongCardViewModel(
                model: song.toCardModel(),
                onMenuTapped: { [weak self] in
                    self?.handleMenuTap(for: songID)
                }
            )
        )
    }
}
