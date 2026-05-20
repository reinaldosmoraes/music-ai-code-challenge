//
//  RecentlyPlayedStoring.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 20/05/26.
//

import Foundation

protocol RecentlyPlayedStoring: Sendable {
    func fetchAll() -> [Song]
    func record(_ song: Song)
}
