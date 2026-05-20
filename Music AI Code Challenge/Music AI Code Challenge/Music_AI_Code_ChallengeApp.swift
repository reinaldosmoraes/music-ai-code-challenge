//
//  Music_AI_Code_ChallengeApp.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import SwiftUI
import SwiftData

@main
struct Music_AI_Code_ChallengeApp: App {
    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    SplashScreenView()
                } else {
                    SongsView()
                }
            }
            .onAppear {
                guard showSplash else { return }
                Task {
                    try? await Task.sleep(for: .seconds(2))
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            }
        }
        .modelContainer(for: RecentlyPlayedSong.self)
    }
}
