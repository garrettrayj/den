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
        VStack(spacing: 12) {
            Spacer()
            Image("TitleIcon").resizable().scaledToFit().frame(width: 100, height: 100)
            Text("Welcome").font(.title).fontWeight(.medium)

            Group {
                if profile.pagesArray.count > 0 {
                    Text("Select a page to view subscriptions")
                } else {
                    Text("Add a page to begin")
                }
            }.foregroundColor(.secondary)

            Spacer()
            Spacer()
        }
    }
}
