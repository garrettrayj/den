//
//  StatusView.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct StatusView: View {
    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    let progress: Progress

    var body: some View {
        VStack {
            if refreshing {
                ProgressView(progress).progressViewStyle(BottomBarProgressViewStyle())
            } else if let refreshedDate = profile.minimumRefreshedDate {
                Text("\(refreshedDate.formatted())").font(.caption)
            } else {
                #if targetEnvironment(macCatalyst)
                Text("Press \(Image(systemName: "command")) + R to refresh")
                    .imageScale(.small)
                    .font(.caption)
                #else
                Text("Pull to refresh").font(.caption)
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
