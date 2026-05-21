//
//  AudioPlaying.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import Foundation

@MainActor
protocol AudioPlaying: AnyObject {
    var isPlaying: Bool { get }
    var currentTime: TimeInterval { get }
    var duration: TimeInterval { get }
    var onPlaybackStateChange: (@MainActor (TimeInterval, TimeInterval, Bool) -> Void)? { get set }

    func prepare(url: URL) async throws
    func play()
    func pause()
    func stop()
    func seek(to time: TimeInterval)
    func skip(by interval: TimeInterval)
}
