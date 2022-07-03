//
//  SidebarPageView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPageView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        Label {
            HStack {
                Text(viewModel.page.displayName).modifier(SidebarItemLabelTextModifier())

                Spacer()

                if editMode?.wrappedValue == .inactive {
                    if viewModel.refreshing {
                        ProgressView().progressViewStyle(IconProgressStyle())
                    } else {
                        Text(String(viewModel.page.unreadPreviewItems.count))
                            .font(.caption.weight(.medium))
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .overlay(
                                Capsule().fill(Color(UIColor.secondarySystemFill))
                            )
                    }
                }
            }.lineLimit(1)
        } icon: {
            Image(systemName: viewModel.page.wrappedSymbol).imageScale(.large)
        }
    }
}
