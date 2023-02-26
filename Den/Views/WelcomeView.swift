//
//  WelcomeView.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var profile: Profile

    var refreshedTimeAgo: String? {
        guard let refreshed = RefreshedDateStorage.shared.getRefreshed(profile) else { return nil }
        return refreshed.formatted(.relative(presentation: .numeric))
    }

    var body: some View {
        Group {
            if let refreshedTimeAgo = refreshedTimeAgo {
                SplashNoteView(title: profile.displayName, note: "Refreshed \(refreshedTimeAgo).")
            } else {
                SplashNoteView(title: profile.displayName)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Text("\(profile.feedsArray.count) feeds").font(.caption)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
