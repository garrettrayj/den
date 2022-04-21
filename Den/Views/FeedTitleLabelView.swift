//
//  FeedTitleLabelView.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

import Kingfisher

struct FeedTitleLabelView: View {
    var title: String
    var favicon: URL?

    var body: some View {
        Label {
            Text(title).lineLimit(1)
        } icon: {
            KFImage(favicon)
                .placeholder({ _ in
                    Image(systemName: "dot.radiowaves.up.forward")
                })
                .resizing(referenceSize: ImageSize.favicon)
                .scaleFactor(UIScreen.main.scale)
                .frame(width: ImageSize.favicon.width, height: ImageSize.favicon.height)
        }
    }
}
