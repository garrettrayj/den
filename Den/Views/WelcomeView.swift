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
        VStack(spacing: 16) {
            Spacer()
            ZStack(alignment: .center) {
                Image(systemName: "hexagon").font(.system(size: 48))
                Image(systemName: "bolt.fill").font(.system(size: 24)).foregroundColor(.accentColor)
            }

            Text(profile.displayName).font(.largeTitle.weight(.semibold))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Text("\(profile.feedsArray.count) feeds").font(.caption)
            }
        }
        .navigationTitle("Den")
    }
}
