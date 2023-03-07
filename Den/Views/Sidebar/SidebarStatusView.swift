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

struct SidebarStatusView: View {
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    let progress: Progress

    @State private var refreshedDate: Date?
    @State private var timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            if refreshing {
                ProgressView(progress).progressViewStyle(
                    BottomBarProgressViewStyle(profile: profile)
                )
            } else if let refreshedDate = refreshedDate {
                if refreshedDate.formatted(date: .complete, time: .omitted) ==
                    Date().formatted(date: .complete, time: .omitted) {
                    Text("Updated at \(refreshedDate.formatted(date: .omitted, time: .shortened))")
                } else {
                    Text("Updated \(refreshedDate.formatted(date: .abbreviated, time: .shortened))")
                }
            } else {
                #if targetEnvironment(macCatalyst)
                Text("Press \(Image(systemName: "command")) + R to Refresh").imageScale(.small)
                #else
                Text("Pull to Refresh")
                #endif
            }
        }
        .font(.caption)
        .lineLimit(1)
        .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
            progress.completedUnitCount += 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .pagesRefreshed)) { _ in
            progress.completedUnitCount += 1
        }
        .task {
            refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile)
        }
        .onDisappear {
            self.timer.upstream.connect().cancel()
        }
        .onAppear {
            self.timer = self.timer.upstream.autoconnect()
        }
    }
}
