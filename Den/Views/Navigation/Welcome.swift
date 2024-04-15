//
//  Welcome.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Welcome: View {
    @FetchRequest(sortDescriptors: [])
    private var feeds: FetchedResults<Feed>
    
    var body: some View {
        ContentUnavailable {
            Label {
                Text("Welcome", comment: "Welcome title.")
            } icon: {
                Image(systemName: "house")
            }
        } description: {
            if feeds.isEmpty {
                Text("No Feeds", comment: "Feed count (zero).")
            } else if feeds.count == 1 {
                Text("1 Feed", comment: "Feed count (singular).")
            } else {
                Text("\(feeds.count) Feeds", comment: "Feed count (plural).")
            }
        }
    }
}
