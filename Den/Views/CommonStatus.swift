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
        VStack {
            if refreshManager.refreshing {
                Text("Checking for New Items…", comment: "Status message.")
            } else {
                if let refreshedDate = RefreshedDateStorage.shared.getRefreshed(profile) {
                    RelativeRefreshedDate(date: refreshedDate)
                }
                secondaryMessage.foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .font(.caption)
        .lineLimit(1)
    }
}
