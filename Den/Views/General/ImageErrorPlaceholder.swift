//
//  ImageErrorPlaceholder.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ImageErrorPlaceholder: View {
    var body: some View {
        Image(systemName: "photo")
            .imageScale(.large)
            .foregroundStyle(.tertiary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
