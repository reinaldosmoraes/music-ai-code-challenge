//
//  SongCardViewModel.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

// MARK: - Model

struct SongCardModel: Equatable, Identifiable, Sendable {
    let id: String
    let title: String
    let subtitle: String
    let artworkURL: URL?

    init(
        id: String = UUID().uuidString,
        title: String,
        subtitle: String,
        artworkURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.artworkURL = artworkURL
    }
}

// MARK: - Presentation contract

protocol SongCardViewModeling {
    var title: String { get }
    var subtitle: String { get }
    var artworkURL: URL? { get }
    var onMenuTapped: (() -> Void)? { get }
}

// MARK: - ViewModel

@Observable final class SongCardViewModel: SongCardViewModeling {
    private let model: SongCardModel
    let onMenuTapped: (() -> Void)?

    var title: String { model.title }
    var subtitle: String { model.subtitle }
    var artworkURL: URL? { model.artworkURL }

    init(model: SongCardModel, onMenuTapped: (() -> Void)? = nil) {
        self.model = model
        self.onMenuTapped = onMenuTapped
    }
}
