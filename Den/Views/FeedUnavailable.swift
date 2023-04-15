//
//  FeedUnavailable.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedUnavailable: View {
    let feedData: FeedData?
    var splashNote: Bool = false

    var body: some View {
        if splashNote {
            SplashNote(title: titleAndDescripition.0, note: titleAndDescripition.1)
        } else {
            VStack(alignment: .leading, spacing: 4) {
                Text(titleAndDescripition.0)
                if let caption = titleAndDescripition.1 {
                    Text(.init(caption)).font(.caption).foregroundColor(.secondary)
                }
            }
            .padding(12)
            .modifier(RoundedContainerModifier())
        }
    }

    var titleAndDescripition: (String, String?) {
        if feedData == nil {
            return ("No Data", "Refresh to get items.")
        } else if let error = feedData?.error {
            return ("Refresh Error", error)
        } else if feedData!.itemsArray.isEmpty {
            return ("Feed Empty", "No items.")
        } else {
            return ("Status Unavailable", nil)
        }
    }
}
