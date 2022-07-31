//
//  TrendsNavView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendsNavView: View {
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    @Binding var refreshing: Bool

    var body: some View {
        NavigationLink {
            TrendsView(profile: profile, refreshing: $refreshing)
        } label: {
            Label {
                HStack {
                    Text("Trends").modifier(SidebarItemLabelTextModifier())
                    Spacer()
                    if editMode?.wrappedValue == .inactive {
                        if refreshing {
                            ProgressView().progressViewStyle(IconProgressStyle())
                        } else {
                            Text(String(profile.previewItems.unread().count))
                                .modifier(CapsuleModifier())
                        }
                    }
                }.lineLimit(1)
            } icon: {
                Image(systemName: "chart.line.uptrend.xyaxis").imageScale(.large)
            }
        }
        .accessibilityIdentifier("timeline-button")
    }
}
