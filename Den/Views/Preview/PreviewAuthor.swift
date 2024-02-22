//
//  PreviewAuthor.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct PreviewAuthor: View {
    let author: String

    var body: some View {
        Text(author).font(.footnote).lineLimit(1)
    }
}
