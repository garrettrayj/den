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

    var refreshedDateTimeAgo: Date? {
        guard let refreshed = RefreshedDateStorage.shared.getRefreshed(profile) else { return nil }
        return refreshed
    }

    @State var refreshedDateTimeStr: String = "Loading.."

    @Binding var refreshing: Bool

    var body: some View {
        let timer = Timer.publish(
            every: 1,
            on: .main,
            in: .common
        ).autoconnect()

        Group {
            if refreshing {
                SplashNoteView(title: profile.displayName, note: "Refreshing feeds...")
            } else if let refreshedDateTimeAgo = RefreshedDateStorage.shared.getRefreshed(profile) {
                SplashNoteView(title: profile.displayName, note: "\(refreshedDateTimeStr).").onReceive(timer) { (_) in
                    if -refreshedDateTimeAgo.timeIntervalSinceNow < 60 {
                        self.refreshedDateTimeStr = "Refreshed a few seconds ago"
                    } else {
                        self.refreshedDateTimeStr = "Refreshed \(refreshedDateTimeAgo.relativeTime())"
                    }
                }
            } else {
                SplashNoteView(title: profile.displayName)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
            self.refreshedDateTimeStr = "Refreshing feeds.."
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Text("\(profile.feedsArray.count) feed\(profile.feedsArray.count > 1 ? "s" : "")").font(.caption)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
