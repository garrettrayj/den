//
//  FeedHero.swift
//  Den
//
//  Created by Garrett Johnson on 2/9/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedHero: View {
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlActiveState
    #endif
    @Environment(\.isEnabled) private var isEnabled
    
    let url: URL

    var body: some View {
        WebImage(
            url: url,
            options: [.decodeFirstFrameOnly, .delayPlaceholder]
        ) { image in
            VStack(spacing: 0) {
                ZStack {
                    image
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                        .padding()
                        .opacity(opacity)
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
                .grayscale(grayscale)
                
                Divider()
            }
            
        } placeholder: {
            VStack {
                ImageErrorPlaceholder()
                Divider()
            }
        }
        .frame(height: 200)
    }
    
    private var grayscale: CGFloat {
        #if os(macOS)
        if controlActiveState == .inactive || !isEnabled {
            return 0.8
        } else {
            return 0
        }
        #else
        if isEnabled {
            return 0
        } else {
            return 0.8
        }
        #endif
    }
    
    private var opacity: CGFloat {
        #if os(macOS)
        if controlActiveState == .inactive {
            return 0.2
        } else if !isEnabled {
            return 0.4
        } else {
            return 1
        }
        #else
        if !isEnabled {
            return 0.4
        } else {
            return 1
        }
        #endif
    }
}
