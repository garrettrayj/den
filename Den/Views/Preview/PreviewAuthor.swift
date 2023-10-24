//
//  PreviewAuthor.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct PreviewAuthor: View {
    let author: String

    var body: some View {
        Text(author).font(.subheadline).lineLimit(1)
    }
}
