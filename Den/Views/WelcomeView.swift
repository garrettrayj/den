//
//  WelcomeView.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    var profileIsEmpty: Bool

    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image("TitleIcon").resizable().scaledToFit().frame(width: 100, height: 100)
            Text("Welcome").font(.largeTitle.weight(.semibold))

            Group {
                if profileIsEmpty {
                    Text("Add a page to begin")
                } else {
                    Text("Select a page to view feeds")
                }
            }.foregroundColor(.secondary)

            Spacer()
            Spacer()
        }
    }
}
