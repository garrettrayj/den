//
//  BlendView.swift
//  Den
//
//  Created by Garrett Johnson on 2/11/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct BlendView: View {
    @EnvironmentObject private var refreshManager: RefreshManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var page: Page

    var visibleItems: [Item]
    var frameSize: CGSize

    var body: some View {
        BoardView(width: frameSize.width, list: visibleItems) { item in
            FeedItemPreviewView(item: item)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
