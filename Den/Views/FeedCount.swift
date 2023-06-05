//
//  FeedCount.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedCount: View {
    let count: Int

    var body: some View {
        Text("\(count) Feed(s)", comment: "Feed count")
            .foregroundColor(.secondary).font(.footnote)
    }
}
