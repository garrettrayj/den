//
//  FeedTitleButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedTitleButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        #if os(macOS)
        if colorScheme == .dark {
            configuration.label
                .font(.title3)
                .padding(12)
                .background(.fill.quaternary)
                .overlay {
                    clipShape.strokeBorder(.separator)
                }
                .clipShape(clipShape)
                .background(.background)
        } else {
            configuration.label
                .font(.title3)
                .padding(12)
                .padding(.bottom, 1)
                .overlay(Divider(), alignment: .bottom)
                .background(.background)
                .clipShape(clipShape)
                .background(.windowBackground)
        }
        #else
        configuration.label
            .font(.title3)
            .padding(12)
            .padding(.bottom, 1)
            .overlay(Divider(), alignment: .bottom)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(clipShape)
            .background(Color(.systemGroupedBackground))
        #endif
    }
    
    private var clipShape: some InsettableShape {
        UnevenRoundedRectangle(
            cornerRadii: .init(topLeading: 8, bottomLeading: 0, bottomTrailing: 0, topTrailing: 8)
        )
    }
}
