//
//  SplashScreenView.swift
//  Music AI Code Challenge
//
//  Created by Reinaldo Moraes on 16/05/26.
//

import SwiftUI

private enum ViewConstants {
    static let appLogoSize = CGFloat(100)
}

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.Background.gradientPrimary,
                    Color.Background.gradientSecondary,
                ],
                startPoint: .bottomLeading,
                endPoint: .topTrailing
            )
            .ignoresSafeArea()

            Image("app-logo")
                .resizable()
                .scaledToFit()
                .frame(
                    width: ViewConstants.appLogoSize,
                    height: ViewConstants.appLogoSize
                )
        }
    }
}

#Preview {
    SplashScreenView()
}
