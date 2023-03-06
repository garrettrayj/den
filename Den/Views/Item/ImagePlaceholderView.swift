//
//  ImagePlaceholderView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ImagePlaceholderView: View {
    var imageScale: Image.Scale = .large

    var body: some View {
        HStack {
            Image(systemName: "photo")
                .imageScale(imageScale)
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
