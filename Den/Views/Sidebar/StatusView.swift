//
//  StatusView.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct StatusView: View {
    @ObservedObject var profile: Profile

    var refreshedDateTimeAgo: Date? {
        guard let refreshed = RefreshedDateStorage.shared.getRefreshed(profile) else { return nil }
        return refreshed
    }

    @Binding var refreshing: Bool

    let progress: Progress

    @State var refreshedDateTimeStr: String = ""

    var body: some View {
        let timer = Timer.publish(
            every: 1,
            on: .main,
            in: .common
        ).autoconnect()

        VStack {
            if refreshing {
                ProgressView(progress).progressViewStyle(
                    BottomBarProgressViewStyle(profile: profile)
                )
            } else if let refreshedDateTimeAgo = RefreshedDateStorage.shared.getRefreshed(profile) {
                #if targetEnvironment(macCatalyst)
                Text("Press \(Image(systemName: "command")) + R to refresh.")
                    .imageScale(.small)
                    .font(.caption)
                #else
                if UIDevice.current.userInterfaceIdiom != .pad {
                    Text(refreshedDateTimeStr).font(.caption).fixedSize()
                        .multilineTextAlignment(TextAlignment.center)
                        .onReceive(timer) { (_) in
                        if -refreshedDateTimeAgo.timeIntervalSinceNow < 60 {
                            self.refreshedDateTimeStr = """
                            \(profile.feedsArray.count) feed\(profile.feedsArray.count > 1 ? "s" : "").
                            Refreshed a few seconds ago.
                            """
                        } else {
                            self.refreshedDateTimeStr = """
                            \(profile.feedsArray.count) feed\(profile.feedsArray.count > 1 ? "s" : "").
                            Refreshed \(refreshedDateTimeAgo.relativeTime()).
                            """
                        }
                    }
                } else {
                    Text("Pull to refresh.").font(.caption)
                }
                #endif
            } else {
                #if targetEnvironment(macCatalyst)
                Text("Press \(Image(systemName: "command")) + R to refresh.")
                    .imageScale(.small)
                    .font(.caption)
                #else
                Text("Pull to refresh.").font(.caption)
                #endif
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
            progress.completedUnitCount += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .pagesRefreshed)) { _ in
            progress.completedUnitCount += 1
        }
    }
}
