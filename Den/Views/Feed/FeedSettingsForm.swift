//
//  FeedSettingsForm.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedSettingsForm: View {
    @ObservedObject var feed: Feed
    
    var body: some View {
        Form {
            FeedSettingsGeneralSection(feed: feed)
            FeedSettingsPreviewsSection(feed: feed)
        }
        .formStyle(.grouped)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationTitle(Text("Feed Settings", comment: "Navigation title."))
    }
}
