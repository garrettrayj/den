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
        welcomeNote
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    if profile.feedsArray.count == 1 {
                        Text("1 Feed", comment: "Welcome view feed count (singular)").font(.caption)
                    } else {
                        Text(
                            "\(profile.feedsArray.count) Feeds",
                            comment: "Welcome view feed count (zero or plural)"
                        )
                        .font(.caption)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var welcomeNote: some View {
        if refreshing {
            SplashNote(
                title: Text(profile.wrappedName),
                note: Text("Checking for New Items…", comment: "Welcome view refreshing status text")
            )
        } else if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
            TimelineView(.everyMinute) { _ in
                if -refreshedDate.timeIntervalSinceNow < 60 {
                    SplashNote(
                        title: profile.nameText,
                        note: Text("Updated Just Now", comment: "Updated in the last minute")
                    )
                } else {
                    SplashNote(
                        title: profile.nameText,
                        note: Text(
                            "Updated \(refreshedDate.formatted(relativeDateStyle))",
                            comment: "Updated more than a minute ago"
                        )
                    )
                }
            }
        } else {
            SplashNote(title: profile.nameText)
        }
    }
}
