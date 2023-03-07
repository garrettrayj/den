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

    @State var progress: Progress

    var body: some View {
        VStack {
            if refreshing {
                ProgressView(progress).progressViewStyle(
                    BottomBarProgressViewStyle(profile: profile)
                )
            } else if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
                if refreshedDate.formatted(date: .complete, time: .omitted) ==
                    Date().formatted(date: .complete, time: .omitted) {
                    Text("Updated at \(refreshedDate.formatted(date: .omitted, time: .shortened))")
                } else {
                    Text("Updated \(refreshedDate.formatted(date: .abbreviated, time: .omitted))")
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
    }
}
