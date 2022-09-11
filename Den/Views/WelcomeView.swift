//
//  WelcomeView.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    @ObservedObject var profile: Profile

    var body: some View {
        StatusBoxView(
            message: Text(profile.displayName),
            caption: Text("Profile Active"),
            symbol: "helm"
        )
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Text("\(profile.feedsArray.count) feeds").font(.caption)
            }
        }
        .navigationTitle("Den")
    }
}
