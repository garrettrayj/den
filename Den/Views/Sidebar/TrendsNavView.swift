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
    @ObservedObject var viewModel: TrendsViewModel

    var body: some View {
        NavigationLink {
            TrendsView(viewModel: viewModel)
        } label: {
            Label {
                HStack {
                    Text("Trends").modifier(SidebarItemLabelTextModifier())
                    Spacer()
                    if editMode?.wrappedValue == .inactive {
                        if viewModel.refreshing {
                            ProgressView().progressViewStyle(IconProgressStyle())
                        } else {
                            Text(String(viewModel.profile.previewItems.unread().count))
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
