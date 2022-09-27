//
//  FeedRefreshedLabelView.swift
//  Den
//
//  Created by Garrett Johnson on 12/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedRefreshedLabelView: View {
    let refreshed: String?

    var body: some View {
        if let refreshed = refreshed {
            Label(refreshed, systemImage: "wave.3.backward")
                .foregroundColor(.secondary)
                .font(.footnote)
                .imageScale(.small)
        }
    }
}
