//
//  SongsView.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import SwiftUI
import UIKit

private enum ViewConstants {
    static let listRowVerticalPadding: CGFloat = 8
    static let listHorizontalPadding: CGFloat = 16
    static let expandedPlayerHeightRatio: CGFloat = 0.92
    static let backdropOpacity: CGFloat = 0.45
}

struct SongsView: View {
    @Bindable private var viewModel: SongsViewModel

    init(viewModel: SongsViewModel = SongsViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Color(.systemBackground)
                        .ignoresSafeArea()

                    content
                        .padding(.bottom, viewModel.miniPlayerBottomInset)

                    if viewModel.playerPresentation == .expanded {
                        Color.black.opacity(ViewConstants.backdropOpacity)
                            .ignoresSafeArea()
                            .transition(.opacity)
                    }

                    if let playerViewModel = viewModel.playerViewModel, viewModel.isPlayerVisible {
                        MusicPlayerView(
                            viewModel: playerViewModel,
                            presentation: $viewModel.playerPresentation,
                            expandedHeight: geometry.size.height * ViewConstants.expandedPlayerHeightRatio,
                            onMinimize: {
                                viewModel.minimizePlayer()
                            },
                            onExpand: {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                    viewModel.expandPlayer()
                                }
                            },
                            onViewAlbum: {
                                dismissKeyboard()
                                viewModel.openCurrentAlbum()
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Search songs")
            .navigationDestination(for: AlbumRoute.self) { route in
                AlbumView(
                    viewModel: AlbumViewModel(
                        route: route,
                        onSelectSong: { song in
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                                viewModel.selectSongFromAlbum(song)
                            }
                        },
                        onSongsLoaded: { songs in
                            viewModel.registerSongs(songs)
                        }
                    )
                )
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: viewModel.playerPresentation)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                viewModel.minimizePlayer()
            }
        }
        .onChange(of: viewModel.playerPresentation) { _, newPresentation in
            if newPresentation == .expanded {
                dismissKeyboard()
            }
        }
        .task {
            viewModel.loadRecentlyPlayed()
        }
        .onChange(of: viewModel.searchText, initial: true) { _, _ in
            Task {
                await viewModel.search()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isShowingSearchResults {
            searchResultsContent
        } else if viewModel.showsRecentlyPlayed {
            songList(items: viewModel.recentlyPlayedItems)
        } else {
            searchForSongsPromptState
        }
    }

    @ViewBuilder
    private var searchResultsContent: some View {
        if viewModel.isLoading, viewModel.songItems.isEmpty {
            ProgressView()
        } else if let errorMessage = viewModel.errorMessage {
            errorState(message: errorMessage)
        } else if viewModel.showsEmptyState {
            emptyState
        } else {
            songList(items: viewModel.songItems)
        }
    }

    private func songList(items: [SongListItem]) -> some View {
        List(items) { item in
            SongCardView(viewModel: item.cardViewModel)
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissKeyboard()
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                        viewModel.selectSong(id: item.id)
                    }
                }
                .listRowInsets(
                    EdgeInsets(
                        top: ViewConstants.listRowVerticalPadding,
                        leading: ViewConstants.listHorizontalPadding,
                        bottom: ViewConstants.listRowVerticalPadding,
                        trailing: ViewConstants.listHorizontalPadding
                    )
                )
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.interactively)
        .overlay {
            if viewModel.isLoading, viewModel.isShowingSearchResults {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 8)
            }
        }
    }

    private var searchForSongsPromptState: some View {
        ContentUnavailableView(
            "Search for songs",
            systemImage: "magnifyingglass",
            description: Text("Find your music on iTunes.")
        )
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No songs found",
            systemImage: "music.note.list",
            description: Text("Try a different search term.")
        )
    }

    private func errorState(message: String) -> some View {
        ContentUnavailableView(
            "Something went wrong",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
    }
}

// MARK: - Preview

#Preview("iTunes") {
    SongsView()
}

#Preview("Mock") {
    SongsView(viewModel: SongsViewModel(songsService: MockSongsService()))
}
