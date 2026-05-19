//
//  ITunesSongMapper.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

enum ITunesSongMapper {
    static func map(_ track: ITunesTrackDTO) -> Song? {
        guard
            let trackId = track.trackId,
            let title = track.trackName?.trimmingCharacters(in: .whitespacesAndNewlines),
            !title.isEmpty,
            let artist = track.artistName?.trimmingCharacters(in: .whitespacesAndNewlines),
            !artist.isEmpty
        else {
            return nil
        }

        let album = track.collectionName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let artworkURL = track.artworkUrl100
            .flatMap(URL.init(string:))
            .map(Self.higherResolutionArtworkURL)
        let previewURL = track.previewUrl.flatMap(URL.init(string:))
        let trackDuration = track.trackTimeMillis.map { TimeInterval($0) / 1_000 }

        let collectionID = track.collectionId.map(String.init)

        return Song(
            id: String(trackId),
            title: title,
            artist: artist,
            album: album?.isEmpty == false ? album : nil,
            collectionID: collectionID,
            artworkURL: artworkURL,
            previewURL: previewURL,
            trackDuration: trackDuration
        )
    }

    static func mapLookupTrack(_ result: ITunesLookupResultDTO, albumName: String?) -> Song? {
        guard
            let trackId = result.trackId,
            let title = result.trackName?.trimmingCharacters(in: .whitespacesAndNewlines),
            !title.isEmpty,
            let artist = result.artistName?.trimmingCharacters(in: .whitespacesAndNewlines),
            !artist.isEmpty
        else {
            return nil
        }

        let album = albumName ?? result.collectionName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let artworkURL = result.artworkUrl100
            .flatMap(URL.init(string:))
            .map(higherResolutionArtworkURL)
        let previewURL = result.previewUrl.flatMap(URL.init(string:))
        let trackDuration = result.trackTimeMillis.map { TimeInterval($0) / 1_000 }
        let collectionID = result.collectionId.map(String.init)

        return Song(
            id: String(trackId),
            title: title,
            artist: artist,
            album: album?.isEmpty == false ? album : nil,
            collectionID: collectionID,
            artworkURL: artworkURL,
            previewURL: previewURL,
            trackDuration: trackDuration
        )
    }

    /// Requests a sharper thumbnail when the API returns a 100×100 artwork URL.
    static func higherResolutionArtworkURL(from url: URL) -> URL {
        let urlString = url.absoluteString
        guard urlString.contains("100x100bb") else { return url }

        return URL(string: urlString.replacingOccurrences(of: "100x100bb", with: "200x200bb")) ?? url
    }
}
