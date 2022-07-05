//
//  GlobalGadgetsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GlobalGadgetsView: View {
    @ObservedObject var profile: Profile
    @EnvironmentObject var linkManager: LinkManager

    @Binding var hideRead: Bool

    var frameSize: CGSize

    var body: some View {
        BoardView(width: frameSize.width, list: profile.feedsArray) { feed in
            GadgetView(feed: feed, hideRead: $hideRead)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
