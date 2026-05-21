//
//  LocalizedString.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

enum LocalizedString {
    // MARK: - Song Card

    static var moreOptions: String { "more_options".localized }

    // MARK: - Songs

    static var songsTitle: String { "songs_title".localized }
    static var searchSongsPrompt: String { "search_songs_prompt".localized }
    static var searchForSongsTitle: String { "search_for_songs_title".localized }
    static var searchForSongsDescription: String { "search_for_songs_description".localized }
    static var noSongsFoundTitle: String { "no_songs_found_title".localized }
    static var noSongsFoundDescription: String { "no_songs_found_description".localized }
    static var errorGenericTitle: String { "error_generic_title".localized }

    // MARK: - Album

    static var albumLoadErrorTitle: String { "album_load_error_title".localized }

    // MARK: - Music Player

    static var viewAlbum: String { "view_album".localized }
    static var swipeDownToMinimize: String { "swipe_down_to_minimize".localized }
    static var previousSong: String { "previous_song".localized }
    static var nextSong: String { "next_song".localized }
    static var play: String { "play".localized }
    static var pause: String { "pause".localized }

    // MARK: - iTunes Errors

    static var itunesErrorEmptySearchTerm: String { "itunes_error_empty_search_term".localized }
    static var itunesErrorInvalidURL: String { "itunes_error_invalid_url".localized }
    static var itunesErrorInvalidResponse: String { "itunes_error_invalid_response".localized }
    static var itunesErrorDecodingFailed: String { "itunes_error_decoding_failed".localized }

    static func itunesErrorHTTPStatus(_ statusCode: Int) -> String {
        "itunes_error_http_status".localized(statusCode)
    }

    // MARK: - Audio Errors

    static var audioErrorConfigureSession: String { "audio_error_configure_session".localized }
    static var audioErrorLoadPreview: String { "audio_error_load_preview".localized }
}
