//
//  FeedHero.swift
//  Den
//
//  Created by Garrett Johnson on 2/9/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedHero: View {
    let url: URL
    
    @ScaledMetric private var height = 200

    var body: some View {
        WebImage(url: url, options: [.decodeFirstFrameOnly, .delayPlaceholder]) { image in
            VStack(spacing: 0) {
                ZStack {
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                        .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background {
                    image
                        .resizable()
                        .scaledToFill()
                        .background(.background)
                        .overlay(.thinMaterial)
                }
                .clipped()
                
                Divider()
            }
            
        } placeholder: {
            VStack {
                ImageErrorPlaceholder()
                Divider()
            }
        }
        .frame(height: height)
    }
}
