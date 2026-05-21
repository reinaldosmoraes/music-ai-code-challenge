//
//  SongCardView.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import SwiftUI

private enum ViewConstants {
    static let artworkSize: CGFloat = 52
    static let artworkCornerRadius: CGFloat = 8
    static let contentSpacing: CGFloat = 12
    static let textSpacing: CGFloat = 2
    static let menuButtonSize: CGFloat = 44
    static let titleSize: CGFloat = 16
    static let subtitleSize: CGFloat = 10
    static let cardLineLimit: Int = 1
    static let buttonFontSize: CGFloat = 16
    static let placeholderIconSize: CGFloat = 20
}

struct SongCardView<ViewModel: SongCardViewModeling>: View {
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(alignment: .center, spacing: ViewConstants.contentSpacing) {
            SongCardArtworkView(url: viewModel.artworkURL)

            VStack(alignment: .leading, spacing: ViewConstants.textSpacing) {
                Text(viewModel.title)
                    .font(.system(size: ViewConstants.titleSize, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(ViewConstants.cardLineLimit)

                Text(viewModel.subtitle)
                    .font(.system(size: ViewConstants.subtitleSize, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(ViewConstants.cardLineLimit)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)

            if let onMenuTapped = viewModel.onMenuTapped {
                Spacer(minLength: ViewConstants.contentSpacing)

                Button(action: onMenuTapped) {
                    AppImages.ellipsis
                        .font(.system(size: ViewConstants.buttonFontSize, weight: .medium))
                        .foregroundStyle(.primary)
                        .frame(
                            width: ViewConstants.menuButtonSize,
                            height: ViewConstants.menuButtonSize
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(LocalizedString.moreOptions)
            }
        }
    }
}

// MARK: - Subviews

private struct SongCardArtworkView: View {
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
        .frame(
            width: ViewConstants.artworkSize,
            height: ViewConstants.artworkSize
        )
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
    VStack(spacing: 8) {
        SongCardView(
            viewModel: SongCardViewModel(
                model: SongCardModel(
                    title: "Purple Rain",
                    subtitle: "Prince",
                    artworkURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Video113/v4/95/20/18/9520186e-1a50-04c0-78ef-e5a73db095ee/pr_source.jpg/60x60bb.jpg")
                ),
                onMenuTapped: {}
            )
        )

        SongCardView(
            viewModel: SongCardViewModel(
                model: SongCardModel(
                    title: "Purple Rain",
                    subtitle: "Prince",
                    artworkURL: nil
                ),
                onMenuTapped: nil
            )
        )
    }
    .padding()
}
