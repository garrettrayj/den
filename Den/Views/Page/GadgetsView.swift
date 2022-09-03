//
//  GadgetsView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GadgetsView: View {
    @ObservedObject var page: Page

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var frameSize: CGSize

    var body: some View {
        ScrollView(.vertical) {
            BoardView(width: frameSize.width, list: page.feedsArray) { feed in
                GadgetView(feed: feed, hideRead: $hideRead, refreshing: $refreshing)
            }
            .padding()
        }
    }
}
