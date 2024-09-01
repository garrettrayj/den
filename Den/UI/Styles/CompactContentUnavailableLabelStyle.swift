//
//  CompactContentUnavailableLabelStyle.swift
//  Den
//
//  Created by Garrett Johnson on 11/14/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct CompactContentUnavailableLabelStyle: LabelStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        VStack(spacing: 8) {
            configuration.icon
                .foregroundStyle(.secondary)
            configuration.title
                .foregroundStyle(.secondary)
        }
        .imageScale(.large)
        .font(.callout)
    }
}
