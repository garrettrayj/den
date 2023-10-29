//
//  FeedHero.swift
//  Den
//
//  Created by Garrett Johnson on 2/9/23.
//  Copyright © 2023 Garrett Johnson
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
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Spacer()
                WebImage(url: url, options: [.decodeFirstFrameOnly, .delayPlaceholder])
                    .resizable()
                    .placeholder { ImageErrorPlaceholder() }
                    .indicator(.activity)
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
                    .padding(.vertical)
                    .padding(.horizontal, 8)
                    .opacity(opacity)
                Spacer()
            }
            .aspectRatio(16/9, contentMode: .fit)
            .frame(maxHeight: 200)
            .background {
                WebImage(url: url, options: [.decodeFirstFrameOnly])
                    .resizable()
                    .scaledToFill()
                    .background(.background)
                    .overlay(.thinMaterial)
            }
            .clipped()
            .grayscale(grayscale)
            
            Divider()
        }
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
