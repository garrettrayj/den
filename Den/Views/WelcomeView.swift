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

    @Binding var refreshing: Bool

    @State private var refreshedDate: Date?
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        Group {
            if refreshing {
                SplashNoteView(title: profile.displayName, note: "Checking for New Items…")
            } else if let refreshedDate = refreshedDate {
                SplashNoteView(
                    title: profile.displayName,
                    note: "Updated \(refreshedDate.formatted(.relative(presentation: .numeric, unitsStyle: .wide)))"
                )
            } else {
                SplashNoteView(title: profile.displayName)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
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
        .task {
            refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile)
        }
        .onReceive(timer) { _ in
            refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile)
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
        .onAppear {
            timer = self.timer.upstream.autoconnect()
        }
    }
}
