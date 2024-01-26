//
//  OrganizerRowStatus.swift
//  Den
//
//  Created by Garrett Johnson on 12/23/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OrganizerRowStatus: View {
    @ObservedObject var feed: Feed
    @ObservedObject var feedData: FeedData
    
    var body: some View {
        if let error = feedData.wrappedError {
            Image(systemName: "bolt.horizontal").foregroundStyle(.red)
            switch error {
            case .parsing:
                Text("Parsing Error", comment: "Organizer row status.")
            case .request:
                Text("Network Error", comment: "Organizer row status.")
            }
        } else {
            if feedData.responseTime > 5 {
                Image(systemName: "tortoise").foregroundStyle(.brown)
            } else if !feed.isSecure {
                Image(systemName: "lock.slash").foregroundStyle(.orange)
            }
            Text(
                "\(Int(feedData.responseTime * 1000)) ms",
                comment: "Milliseconds time display."
            )
        }
    }
}
