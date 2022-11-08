//
//  AllItemsNavView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AllItemsNavView: View {
    @Environment(\.editMode) private var editMode
    @EnvironmentObject private var haptics: Haptics
    @ObservedObject var profile: Profile
    @Binding var unreadCount: Int

    var body: some View {
        NavigationLink(value: Panel.allItems) {
            Label {
                Text("All Items").lineLimit(1)
            } icon: {
                Image(systemName: unreadCount > 0 ? "tray.full": "tray")
            }
        }
        .badge(profile.previewItems.unread().count)
        .accessibilityIdentifier("timeline-button")
    }
}
