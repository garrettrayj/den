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
            if faviconImage == nil {
                Image(systemName: "dot.radiowaves.up.forward")
                    .foregroundColor(Color.secondary)
                    .font(.system(size: 14).weight(.semibold))
                    .frame(
                        width: ImageSize.favicon.width,
                        height: ImageSize.favicon.height,
                        alignment: .center
                    )
                    .clipped()
            } else {
                faviconImage
                    .frame(
                        width: ImageSize.favicon.width,
                        height: ImageSize.favicon.height,
                        alignment: .center
                    )
                    .clipped()
            }
        }
    }
}
