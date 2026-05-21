//
//  ITunesAlbumMapper.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

enum ITunesAlbumMapper {
    static func map(
        _ response: ITunesLookupResponse,
        collectionID: String,
        fallbackTitle: String,
        fallbackArtist: String,
        fallbackArtworkURL: URL?
    ) -> AlbumDetail? {
        let collectionResult = response.results.first {
            $0.wrapperType == "collection" && String($0.collectionId ?? -1) == collectionID
        }

        let albumTitle = normalizedString(collectionResult?.collectionName) ?? fallbackTitle
        let albumArtist = normalizedString(collectionResult?.artistName) ?? fallbackArtist

        let albumArtworkURL = collectionResult?.artworkUrl100
            .flatMap(URL.init(string:))
            .map(ITunesSongMapper.higherResolutionArtworkURL)
            ?? fallbackArtworkURL

        let album = Album(
            id: collectionID,
            title: albumTitle,
            artist: albumArtist,
            artworkURL: albumArtworkURL
        )

        let songs = response.results
            .filter { $0.wrapperType == "track" }
            .sorted { ($0.trackNumber ?? Int.max) < ($1.trackNumber ?? Int.max) }
            .compactMap { ITunesSongMapper.mapLookupTrack($0, albumName: albumTitle) }

        guard !songs.isEmpty else { return nil }

        return AlbumDetail(album: album, songs: songs)
    }

    private static func normalizedString(_ value: String?) -> String? {
        guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !trimmed.isEmpty else {
            return nil
        }
        return trimmed
    }
}
