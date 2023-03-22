//
//  ButtonChevron.swift
//  Den
//
//  Created by Garrett Johnson on 2/5/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ButtonChevron: View {
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        Image(systemName: "chevron.forward")
            .foregroundColor(
                isEnabled ? Color(.tertiaryLabel) : Color(.quaternaryLabel)
            )
            .imageScale(.small)
            .font(.body.weight(.semibold))
    }
}
