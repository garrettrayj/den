//
//  PreviewTeaser.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PreviewTeaser: View {
    let teaser: String

    var body: some View {
        Text(teaser).font(.subheadline.leading(.tight)).lineLimit(4)
    }
}
