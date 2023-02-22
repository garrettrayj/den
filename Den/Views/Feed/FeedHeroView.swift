//
//  FeedHeroView.swift
//  Den
//
//  Created by Garrett Johnson on 2/9/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedHeroView: View {
    let heroImage: URL

    var body: some View {
        VStack(spacing: 0) {
            WebImage(url: heroImage)
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
                .shadow(radius: 3, x: 1, y: 2)
                .padding()
                .frame(maxWidth: 400, maxHeight: 240)
        }
        .frame(maxWidth: .infinity)
        .background {
            WebImage(url: heroImage)
                .resizable()
                .scaledToFill()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .overlay(.thinMaterial)
        }
        .clipped()
    }
}
