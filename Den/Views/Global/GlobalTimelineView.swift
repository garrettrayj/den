//
//  GlobalTimelineView.swift
//  Den
//
//  Created by Garrett Johnson on 7/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct GlobalTimelineView: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool

    var frameSize: CGSize

    var body: some View {
        if profile.previewItems.isEmpty {
            StatusBoxView(message: Text("Timeline Empty"), symbol: "clock")
        } else {
            BoardView(width: frameSize.width, list: visibleItems) { item in
                FeedItemPreviewView(item: item)
            }
            .padding()
        }
    }

    private var visibleItems: [Item] {
        profile.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }
}
