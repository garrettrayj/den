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

    @Binding var refreshing: Bool

    @State private var refreshedDate: Date?
    @State private var refreshedRelativeString: String?
    @State private var timer = Timer.publish(every: 30, on: .main, in: .common).autoconnect()

    let relativeDateStyle: Date.RelativeFormatStyle = .relative(presentation: .named, unitsStyle: .wide)

    var body: some View {
        Group {
            if refreshing {
                SplashNoteView(title: profile.displayName, note: "Checking for New Items…")
            } else if let refreshedDate = refreshedDate, let refreshedRelativeString = refreshedRelativeString {
                if -refreshedDate.timeIntervalSinceNow < 60 {
                    SplashNoteView(title: profile.displayName, note: "Updated Just Now")
                } else {
                    SplashNoteView(title: profile.displayName, note: "Updated \(refreshedRelativeString)")
                }
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
            updateRefreshedDateAndRelativeString()
        }
        .onReceive(timer) { _ in
            updateRefreshedDateAndRelativeString()
        }
        .onChange(of: refreshing) { _ in
            updateRefreshedDateAndRelativeString()
        }
        .onDisappear {
            timer.upstream.connect().cancel()
        }
        .onAppear {
            timer = self.timer.upstream.autoconnect()
        }
    }

    private func updateRefreshedDateAndRelativeString() {
        if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
            self.refreshedDate = refreshedDate
            self.refreshedRelativeString = refreshedDate.formatted(relativeDateStyle)
        }
    }
}
