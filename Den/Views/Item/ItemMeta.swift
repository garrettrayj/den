//
//  ItemMeta.swift
//  Den
//
//  Created by Garrett Johnson on 7/14/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemMeta: View {
    @ObservedObject var item: Item
    
    var body: some View {
        HStack(spacing: 4) {
            if item.bookmarked {
                Image(systemName: "bookmark")
                    .symbolVariant(.fill)
                    .font(.caption2)
                    .imageScale(.small)
            }
            
            if let published = item.published {
                PreviewDateline(date: published)
            }
        }
    }
}
