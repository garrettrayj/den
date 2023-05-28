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
                    Text(profile.feedCountString).font(.caption)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var welcomeNote: some View {
        if refreshing {
            SplashNote(
                title: Text(profile.displayName),
                note: Text("Checking for New Items…")
            )
        } else if let refreshedLabel = refreshedLabel() {
            TimelineView(.everyMinute) { _ in
                SplashNote(title: Text(profile.displayName), note: Text(refreshedLabel))
            }
        } else {
            SplashNote(title: Text(profile.displayName))
        }
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
