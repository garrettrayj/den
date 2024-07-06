//
//  ItemPreviewMeta.swift
//  Den
//
//  Created by Garrett Johnson on 7/3/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemPreviewMeta: View {
    @Bindable var item: Item
    
    var body: some View {
        HStack(spacing: 4) {
            if item.wrappedBookmarked {
                Image(systemName: "bookmark").symbolVariant(.fill).imageScale(.small)
            }
            
            if let date = item.published {
                PreviewDateline(date: date)
            } else {
                Text("Missing Date", comment: "Missing date label.").italic()
            }
        }
        .font(.caption2)
    }
}
