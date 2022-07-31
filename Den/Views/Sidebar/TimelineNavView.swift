//
//  GlobalSidebarItemView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TimelineNavView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: TimelineViewModel

    var body: some View {
        NavigationLink {
            TimelineView(
                viewModel: viewModel
            )
        } label: {
            Label {
                HStack {
                    Text("Timeline").modifier(SidebarItemLabelTextModifier())
                    Spacer()
                    if editMode?.wrappedValue == .inactive {
                        if viewModel.refreshing {
                            ProgressView().progressViewStyle(IconProgressStyle())
                        } else {
                            Text(String(viewModel.unread))
                                .modifier(CapsuleModifier())
                        }
                    }
                }.lineLimit(1)
            } icon: {
                Image(systemName: "calendar.day.timeline.leading").imageScale(.large)
            }
        }
        .accessibilityIdentifier("timeline-button")
    }
}
