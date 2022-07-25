//
//  NoFeedsView.swift
//  Den
//
//  Created by Garrett Johnson on 7/24/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NoFeedsView: View {
    var body: some View {
        #if targetEnvironment(macCatalyst)
        StatusBoxView(
            message: Text("No Feeds"),
            caption: Text("""
            Add feeds by opening syndication links \
            or click \(Image(systemName: "plus.circle")) to add by web address
            """),
            symbol: "questionmark.square.dashed"
        )
        #else
        StatusBoxView(
            message: Text("No Feeds"),
            caption: Text("""
            Add feeds by opening syndication links \
            or tap \(Image(systemName: "ellipsis.circle")) then \(Image(systemName: "plus.circle")) \
            to add by web address
            """),
            symbol: "questionmark.folder"
        )
        #endif
    }
}
