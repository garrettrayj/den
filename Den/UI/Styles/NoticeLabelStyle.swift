//
//  NoticeLabelStyle.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

/** Vertically stacked label for short content availability messages. */
struct NoticeLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 16) {
            configuration.icon
                .imageScale(.large)
                .foregroundStyle(.tertiary)
                .fontWeight(.semibold)

            configuration.title
                .foregroundStyle(.secondary)
                .fontWeight(.bold)
        }
        .font(.title2)
    }
}
