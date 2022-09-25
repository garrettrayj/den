//
//  ImagePlaceholderView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemImagePlaceholderView: View {
    var body: some View {
        HStack {
            Image(systemName: "photo")
                .imageScale(.large)
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
