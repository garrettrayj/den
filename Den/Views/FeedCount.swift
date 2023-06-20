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
        if count == 1 {
            Text("1 Feed", comment: "Feed count (singular).")
        } else {
            Text("\(count) Feeds", comment: "Feed count (zero/plural).")
        }
    }
}
