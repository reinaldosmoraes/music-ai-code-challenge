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
}

struct SongCardView<ViewModel: SongCardViewModeling>: View {
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        HStack(alignment: .center, spacing: ViewConstants.contentSpacing) {
            SongCardArtworkView(artwork: viewModel.artwork)

            VStack(alignment: .leading, spacing: ViewConstants.textSpacing) {
                Text(viewModel.title)
                    .font(.system(size: ViewConstants.titleSize, weight: .medium))
                    .foregroundStyle(Color.Label.primary)
                    .lineLimit(1)

                Text(viewModel.subtitle)
                    .font(.system(size: ViewConstants.subtitleSize, weight: .medium))
                    .foregroundStyle(Color.Label.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)

            if let onMenuTapped = viewModel.onMenuTapped {
                Spacer(minLength: ViewConstants.contentSpacing)

                Button(action: onMenuTapped) {
                    AppImages.ellipsis
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.Label.primary)
                        .frame(
                            width: ViewConstants.menuButtonSize,
                            height: ViewConstants.menuButtonSize
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("More options")
            }
        }
    }
}

// MARK: - Subviews

private struct SongCardArtworkView: View {
    let artwork: SongCardArtwork

    var body: some View {
        Group {
            switch artwork {
            case .asset(let name):
                Image(name)
                    .resizable()
                    .scaledToFill()
            case .placeholder:
                Image(systemName: "music.note")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.Label.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.Label.secondary.opacity(0.15))
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
}

// MARK: - Preview

#Preview {
    VStack(spacing: 8) {
        SongCardView(
            viewModel: SongCardViewModel(
                model: SongCardModel(
                    title: "Purple Rain",
                    subtitle: "Prince",
                    artwork: .asset(name: "app-logo")
                ),
                onMenuTapped: {}
            )
        )

        SongCardView(
            viewModel: SongCardViewModel(
                model: SongCardModel(
                    title: "Purple Rain",
                    subtitle: "Prince",
                    artwork: .asset(name: "app-logo")
                ),
                onMenuTapped: nil
            )
        )
    }
    .padding()
}
