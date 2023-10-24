//
//  ImageErrorPlaceholder.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct ImageErrorPlaceholder: View {
    var imageScale: Image.Scale = .large

    var body: some View {
        Image(systemName: "photo")
            .imageScale(imageScale)
            .foregroundStyle(.tertiary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
