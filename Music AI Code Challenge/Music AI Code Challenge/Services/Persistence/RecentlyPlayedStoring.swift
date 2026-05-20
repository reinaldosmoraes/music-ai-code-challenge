//
//  RecentlyPlayedStoring.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation

@MainActor
protocol RecentlyPlayedStoring {
    func fetchAll() -> [Song]
    func record(_ song: Song)
}
