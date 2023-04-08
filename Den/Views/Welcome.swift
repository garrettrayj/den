//
//  Welcome.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Welcome: View {
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    let relativeDateStyle: Date.RelativeFormatStyle = .relative(presentation: .named, unitsStyle: .wide)

    var body: some View {
        Group {
            if refreshing {
                SplashNote(title: profile.displayName, note: "Checking for New Items…")
            } else if refreshedLabel() != nil {
                TimelineView(.everyMinute) { _ in
                    SplashNote(title: profile.displayName, note: refreshedLabel())
                }
            } else {
                if profile.pagesArray.isEmpty {
                    SplashNote(title: profile.displayName, note: "Welcome! See the sidebar to begin.")
                } else {
                    SplashNote(title: profile.displayName, note: "Last refresh date unavailable.")
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                if profile.feedsArray.count == 1 {
                    Text("1 Feed").font(.caption)
                } else {
                    Text("\(profile.feedsArray.count) Feeds").font(.caption)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func refreshedLabel() -> String? {
        if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
            if -refreshedDate.timeIntervalSinceNow < 60 {
                return "Updated Just Now"
            }
            return "Updated \(refreshedDate.formatted(relativeDateStyle))"
        }
        return nil
    }
}
