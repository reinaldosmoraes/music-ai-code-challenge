//
//  SongsView.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import SwiftUI

private enum ViewConstants {
    static let listRowVerticalPadding: CGFloat = 8
    static let listHorizontalPadding: CGFloat = 16
}

struct SongsView: View {
    @Bindable private var viewModel: SongsViewModel

    init(viewModel: SongsViewModel = SongsViewModel()) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Songs")
                .navigationBarTitleDisplayMode(.large)
                .searchable(text: $viewModel.searchText, prompt: "Search songs")
                .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onChange(of: viewModel.searchText, initial: true) { _, _ in
            Task {
                await viewModel.search()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading, viewModel.songItems.isEmpty {
            ProgressView()
        } else if let errorMessage = viewModel.errorMessage {
            errorState(message: errorMessage)
        } else if viewModel.isSearchPromptVisible {
            searchPromptState
        } else if viewModel.showsEmptyState {
            emptyState
        } else {
            songsList
        }
    }

    private var songsList: some View {
        List(viewModel.songItems) { item in
            SongCardView(viewModel: item.cardViewModel)
                .listRowInsets(
                    EdgeInsets(
                        top: ViewConstants.listRowVerticalPadding,
                        leading: ViewConstants.listHorizontalPadding,
                        bottom: ViewConstants.listRowVerticalPadding,
                        trailing: ViewConstants.listHorizontalPadding
                    )
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.top, 8)
            }
        }
    }

    private var searchPromptState: some View {
        ContentUnavailableView(
            "Search iTunes",
            systemImage: "magnifyingglass",
            description: Text("Type at least 2 characters to search iTunes.")
        )
        .foregroundStyle(Color.Label.primary)
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No songs found",
            systemImage: "music.note.list",
            description: Text("Try a different search term.")
        )
        .foregroundStyle(Color.Label.primary)
    }

    private func errorState(message: String) -> some View {
        ContentUnavailableView(
            "Something went wrong",
            systemImage: "exclamationmark.triangle",
            description: Text(message)
        )
        .foregroundStyle(Color.Label.primary)
    }
}

// MARK: - Preview

#Preview("iTunes") {
    SongsView()
}

#Preview("Mock") {
    SongsView(viewModel: SongsViewModel(songsService: MockSongsService()))
}
