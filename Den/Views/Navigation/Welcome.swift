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
            Text("\(feeds.count) Feeds", comment: "Feed count.")
        }
    }
}
