//
//  CommonStatus.swift
//  Den
//
//  Created by Garrett Johnson on 3/6/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

/**
 Common bottom bar with relative updated time and unread count.
 */
struct CommonStatus<Content: View>: View {
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    var secondaryMessage: Content

    var body: some View {
        Group {
            if refreshManager.refreshing {
                Text("Checking for New Items…", comment: "Status message.")
            } else {
                ViewThatFits {
                    HStack(spacing: 0) {
                        if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
                            RelativeRefreshedDate(date: refreshedDate)
                        }
                        Text(verbatim: " - ").foregroundColor(.secondary)
                        secondaryMessage.foregroundColor(.secondary)
                    }
                    VStack {
                        if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
                            RelativeRefreshedDate(date: refreshedDate)
                        }
                        secondaryMessage.foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .font(.caption)
        .lineLimit(1)
    }
}
