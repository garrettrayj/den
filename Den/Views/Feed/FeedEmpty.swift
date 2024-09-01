//
//  FeedEmpty.swift
//  Den
//
//  Created by Garrett Johnson on 6/26/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedEmpty: View {
    var largeDisplay: Bool = false

    var body: some View {
        if largeDisplay {
            ContentUnavailable {
                Label {
                    Text("Feed Empty", comment: "Content unavailable title.")
                } icon: {
                    Image(systemName: "questionmark.folder")
                }
            }
        } else {
            CompactContentUnavailable {
                Label {
                    Text("Feed Empty", comment: "Content unavailable title.")
                } icon: {
                    Image(systemName: "questionmark.folder")
                }
            }
        }
    }
}
