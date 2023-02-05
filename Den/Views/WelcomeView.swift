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

    var refreshedTimeAgo: String? {
        guard let minRefreshed = profile.minimumRefreshedDate else { return nil }
        return minRefreshed.formatted(.relative(presentation: .numeric))
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Text(profile.displayName).font(.largeTitle)
            if let refreshedText = refreshedTimeAgo {
                Text("Refreshed \(refreshedText)")
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Text("\(profile.feedsArray.count) feeds").font(.caption)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}
