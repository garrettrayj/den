//
//  FeedTitleLabelView.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedTitleLabelView: View {
    var title: String
    var faviconImage: Image?

    var body: some View {
        Label {
            Text(title).lineLimit(1)
        } icon: {
            if faviconImage != nil {
                faviconImage!
                    .resizable()
                    .scaledToFill()
                    .frame(width: 16, height: 16)
                    .clipped()
            } else {
                Image(systemName: "dot.radiowaves.up.forward")
                    .foregroundColor(Color.secondary)
            }
        }
    }
}
