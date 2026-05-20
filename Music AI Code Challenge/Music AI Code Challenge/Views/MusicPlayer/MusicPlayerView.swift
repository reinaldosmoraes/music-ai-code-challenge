//
//  MusicPlayerView.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import SwiftUI

private enum ViewConstants {
    static let artworkSize: CGFloat = 280
    static let artworkCornerRadius: CGFloat = 16
    static let placeholderIconSize: CGFloat = 48
    static let titleSize: CGFloat = 32
    static let artistSize: CGFloat = 16
    static let miniTitleSize: CGFloat = 16
    static let miniArtistSize: CGFloat = 14
    static let controlsSpacing: CGFloat = 32
    static let transportSpacing: CGFloat = 40
    static let transportButtonSize: CGFloat = 44
    static let playPauseButtonSize: CGFloat = 64
    static let bottomPadding: CGFloat = 40
    static let horizontalPadding: CGFloat = 24
    static let timelineSpacing: CGFloat = 8
    static let miniPlayerHeight: CGFloat = 88
    static let cornerRadius: CGFloat = 20
    static let dragIndicatorWidth: CGFloat = 36
    static let dragIndicatorHeight: CGFloat = 5
    static let minimizeDragThreshold: CGFloat = 80
    static let minimizeSpringAnimation = Animation.spring(response: 0.35, dampingFraction: 0.86)
}

struct MusicPlayerView: View {
    @Bindable var viewModel: MusicPlayerViewModel
    @Binding var presentation: MusicPlayerPresentation
    let expandedHeight: CGFloat
    let onMinimize: () -> Void
    let onExpand: () -> Void
    let onViewAlbum: () -> Void

    @State private var dragOffset: CGFloat = 0

    private var isExpanded: Bool {
        presentation == .expanded
    }

    private var isMinimized: Bool {
        presentation == .minimized
    }

    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                dragHandle
            }

            Group {
                if isExpanded {
                    expandedContent
                } else if isMinimized {
                    minimizedContent
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: isExpanded ? expandedHeight : ViewConstants.miniPlayerHeight)
        .background(Color(.secondarySystemBackground))
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: ViewConstants.cornerRadius,
                topTrailingRadius: ViewConstants.cornerRadius
            )
        )
        .shadow(color: .black.opacity(0.25), radius: 16, y: -4)
        .offset(y: dragOffset)
        .gesture(minimizeDragGesture)
        .task {
            await viewModel.onAppear()
        }
    }

    // MARK: - Drag handle

    private var dragHandle: some View {
        Capsule()
            .fill(Color.secondary.opacity(0.5))
            .frame(
                width: ViewConstants.dragIndicatorWidth,
                height: ViewConstants.dragIndicatorHeight
            )
            .padding(.top, 8)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity)
            .accessibilityLabel("Swipe down to minimize")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                animateMinimizeFromDragPosition()
            }
    }

    private var minimizeDragGesture: some Gesture {
        DragGesture(minimumDistance: 10, coordinateSpace: .local)
            .onChanged { value in
                guard presentation == .expanded else { return }

                let isVerticalDrag = abs(value.translation.height) > abs(value.translation.width)
                guard isVerticalDrag, value.translation.height > 0 else { return }
                dragOffset = value.translation.height
            }
            .onEnded { value in
                guard presentation == .expanded else {
                    dragOffset = 0
                    return
                }

                let isVerticalDrag = abs(value.translation.height) > abs(value.translation.width)
                let shouldMinimize = isVerticalDrag && (
                    value.translation.height > ViewConstants.minimizeDragThreshold
                        || value.predictedEndTranslation.height > ViewConstants.minimizeDragThreshold
                )

                if shouldMinimize {
                    animateMinimizeFromDragPosition()
                } else {
                    withAnimation(ViewConstants.minimizeSpringAnimation) {
                        dragOffset = 0
                    }
                }
            }
    }

    private func animateMinimizeFromDragPosition() {
        withAnimation(ViewConstants.minimizeSpringAnimation) {
            dragOffset = 0
            onMinimize()
        }
    }

    // MARK: - Expanded

    private var expandedContent: some View {
        ZStack {
            if viewModel.isLoading, viewModel.errorMessage == nil {
                ProgressView()
            } else {
                VStack(spacing: 0) {
                    Spacer()

                    MusicPlayerArtworkView(url: viewModel.artworkURL)
                        .padding(.horizontal, ViewConstants.horizontalPadding)

                    Spacer()

                    VStack(spacing: ViewConstants.controlsSpacing) {
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: ViewConstants.artistSize, weight: .medium))
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.title)
                                    .font(.system(size: ViewConstants.titleSize, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)

                                Text(viewModel.artist)
                                    .font(.system(size: ViewConstants.artistSize, weight: .medium))
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }

                        timelineView
                        transportControls
                    }
                    .padding(.horizontal, ViewConstants.horizontalPadding)
                    .padding(.bottom, ViewConstants.bottomPadding)
                }
            }
        }
    }

    // MARK: - Minimized

    private var minimizedContent: some View {
        HStack(spacing: 12) {
            HStack(spacing: 12) {
                MusicPlayerArtworkView(
                    url: viewModel.artworkURL,
                    size: 52,
                    cornerRadius: 8,
                    placeholderIconSize: 20
                )

                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.title)
                        .font(.system(size: ViewConstants.miniTitleSize, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    Text(viewModel.artist)
                        .font(.system(size: ViewConstants.miniArtistSize, weight: .medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                onExpand()
            }

            Button("View album") {
                onViewAlbum()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(.primary)
            .buttonStyle(.plain)
            .disabled(!viewModel.canViewAlbum)
        }
        .padding(.horizontal, ViewConstants.horizontalPadding)
        .padding(.vertical, 12)
    }

    // MARK: - Controls

    private var timelineView: some View {
        VStack(spacing: ViewConstants.timelineSpacing) {
            Slider(
                value: Binding(
                    get: { viewModel.playbackProgress },
                    set: { viewModel.seek(to: $0) }
                )
            )
            .tint(.primary)
            .disabled(viewModel.errorMessage != nil)

            HStack {
                Text(viewModel.formattedCurrentTime)
                Spacer()
                Text(viewModel.formattedRemainingTime)
            }
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
    }

    private var transportControls: some View {
        HStack(spacing: ViewConstants.transportSpacing) {
            transportButton(
                image: AppImages.backward,
                accessibilityLabel: "Previous song",
                isEnabled: viewModel.canPlayPrevious,
                action: {
                    Task {
                        await viewModel.playPreviousTrack()
                    }
                }
            )

            Button(action: viewModel.togglePlayPause) {
                Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 32, weight: .semibold))
                    .foregroundStyle(.primary)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(
                        width: ViewConstants.playPauseButtonSize,
                        height: ViewConstants.playPauseButtonSize
                    )
            }
            .buttonStyle(.glass)
            .buttonBorderShape(.circle)
            .accessibilityLabel(viewModel.isPlaying ? "Pause" : "Play")
            .disabled(viewModel.errorMessage != nil)

            transportButton(
                image: AppImages.forward,
                accessibilityLabel: "Next song",
                isEnabled: viewModel.canPlayNext,
                action: {
                    Task {
                        await viewModel.playNextTrack()
                    }
                }
            )
        }
    }

    private func transportButton(
        image: Image,
        accessibilityLabel: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            image
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(isEnabled ? .primary : .secondary)
                .frame(
                    width: ViewConstants.transportButtonSize,
                    height: ViewConstants.transportButtonSize
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .disabled(viewModel.errorMessage != nil || !isEnabled)
    }

}

// MARK: - Artwork

private struct MusicPlayerArtworkView: View {
    let url: URL?
    var size: CGFloat = ViewConstants.artworkSize
    var cornerRadius: CGFloat = ViewConstants.artworkCornerRadius
    var placeholderIconSize: CGFloat = ViewConstants.placeholderIconSize

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
        .frame(width: size, height: size)
        .clipShape(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        )
        .accessibilityHidden(true)
    }

    private var artworkPlaceholder: some View {
        Image(systemName: "photo")
            .font(.system(size: placeholderIconSize, weight: .medium))
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.secondary.opacity(0.15))
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var presentation: MusicPlayerPresentation = .expanded

        var body: some View {
            let song = Song(
                title: "Purple Rain",
                artist: "Prince",
                album: "Purple Rain",
                previewURL: URL(string: "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")
            )

            if let model = MusicPlayerModel(song: song) {
                MusicPlayerView(
                    viewModel: MusicPlayerViewModel(model: model),
                    presentation: $presentation,
                    expandedHeight: 600,
                    onMinimize: { presentation = .minimized },
                    onExpand: { presentation = .expanded },
                    onViewAlbum: {}
                )
            }
        }
    }

    return PreviewWrapper()
}
