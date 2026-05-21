//
//  AlbumView.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import SwiftUI

private enum ViewConstants {
    static let artworkSize: CGFloat = 120
    static let artworkCornerRadius: CGFloat = 8
    static let placeholderIconSize: CGFloat = 32
    static let titleSize: CGFloat = 20
    static let artistSize: CGFloat = 14
    static let headerSpacing: CGFloat = 12
    static let sectionSpacing: CGFloat = 24
    static let horizontalPadding: CGFloat = 16
    static let listRowVerticalPadding: CGFloat = 8
}

struct AlbumView: View {
    @State private var viewModel: AlbumViewModel

    init(viewModel: AlbumViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isLoading, viewModel.songItems.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let errorMessage = viewModel.errorMessage, viewModel.songItems.isEmpty {
                ContentUnavailableView(
                    LocalizedString.albumLoadErrorTitle,
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage)
                )
            } else {
                albumContent
            }
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.onAppear()
        }
    }

    private var albumContent: some View {
        List {
            Section {
                albumHeader
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            Section {
                ForEach(viewModel.songItems) { item in
                    SongCardView(viewModel: item.cardViewModel)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectSong(id: item.id)
                        }
                        .listRowInsets(
                            EdgeInsets(
                                top: ViewConstants.listRowVerticalPadding,
                                leading: ViewConstants.horizontalPadding,
                                bottom: ViewConstants.listRowVerticalPadding,
                                trailing: ViewConstants.horizontalPadding
                            )
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }

    private var albumHeader: some View {
        VStack(alignment: .center, spacing: ViewConstants.headerSpacing) {
            AlbumArtworkView(url: viewModel.artworkURL)

            Text(viewModel.title)
                .font(.system(size: ViewConstants.titleSize, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(viewModel.artist)
                .font(.system(size: ViewConstants.artistSize, weight: .medium))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, ViewConstants.horizontalPadding)
        .padding(.top, ViewConstants.sectionSpacing)
        .padding(.bottom, ViewConstants.headerSpacing)
    }
}

// MARK: - Artwork

private struct AlbumArtworkView: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        artworkPlaceholder
                    @unknown default:
                        artworkPlaceholder
                    }
                }
            } else {
                artworkPlaceholder
            }
        }
        .frame(width: ViewConstants.artworkSize, height: ViewConstants.artworkSize)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ViewConstants.artworkCornerRadius,
                style: .continuous
            )
        )
        .accessibilityHidden(true)
    }

    private var artworkPlaceholder: some View {
        Image(systemName: "photo")
            .font(.system(size: ViewConstants.placeholderIconSize, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.secondary.opacity(0.15))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AlbumView(
            viewModel: AlbumViewModel(
                route: AlbumRoute(
                    collectionID: "1440813271",
                    fallbackTitle: "Purple Rain",
                    fallbackArtist: "Prince"
                ),
                onSelectSong: { _ in },
                onSongsLoaded: { _ in }
            )
        )
    }
}
