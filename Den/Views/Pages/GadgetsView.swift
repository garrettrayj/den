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

    var frameSize: CGSize

    var body: some View {
        ScrollView(.vertical) { content }
    }

    var content: some View {
        BoardView(width: frameSize.width, list: page.feedsArray) { feed in
            GadgetView(feed: feed)
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 38)
    }
}
