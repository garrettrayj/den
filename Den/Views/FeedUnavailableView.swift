//
//  FeedUnavailableView.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedUnavailableView: View {
    let feedData: FeedData?
    var splashNote: Bool = false

    var body: some View {
        if splashNote {
            SplashNoteView(title: titleAndDescripition.0, note: titleAndDescripition.1)
        } else {
            FeedStatusView(title: titleAndDescripition.0, caption: titleAndDescripition.1)
        }
    }

    var titleAndDescripition: (String, String?) {
        if feedData == nil {
            return ("No Data", "Refresh to get content.")
        } else if let error = feedData?.error {
            return ("Refresh Error", error)
        } else if feedData!.itemsArray.isEmpty {
            return ("Feed Empty", "No items.")
        } else {
            return ("Status Unavailable", nil)
        }
    }
}
