//
//  SongCardViewModel.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

// MARK: - Model

struct SongCardModel: Equatable, Identifiable, Sendable {
    let id: UUID
    let title: String
    let subtitle: String
    let artwork: SongCardArtwork

    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        artwork: SongCardArtwork = .placeholder
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.artwork = artwork
    }
}

enum SongCardArtwork: Equatable, Sendable {
    case asset(name: String)
    case placeholder
}

// MARK: - Presentation contract

protocol SongCardViewModeling {
    var title: String { get }
    var subtitle: String { get }
    var artwork: SongCardArtwork { get }
    var onMenuTapped: (() -> Void)? { get }
}

// MARK: - ViewModel

@Observable final class SongCardViewModel: SongCardViewModeling {
    private let model: SongCardModel
    let onMenuTapped: (() -> Void)?

    var title: String { model.title }
    var subtitle: String { model.subtitle }
    var artwork: SongCardArtwork { model.artwork }

    init(model: SongCardModel, onMenuTapped: (() -> Void)? = nil) {
        self.model = model
        self.onMenuTapped = onMenuTapped
    }
}
