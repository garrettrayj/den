//
//  PageGadgetsView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageGadgetsView: View {
    @ObservedObject var page: Page
    @EnvironmentObject var linkManager: LinkManager

    @Binding var hideRead: Bool

    var frameSize: CGSize

    var body: some View {
        BoardView(width: frameSize.width, list: page.feedsArray) { feed in
            GadgetView(feed: feed, hideRead: $hideRead)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
