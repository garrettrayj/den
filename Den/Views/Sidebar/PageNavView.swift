//
//  PageNavView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageNavView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        NavigationLink {
            PageView(viewModel: viewModel)
        } label: {
            Label {
                HStack {
                    Text(viewModel.page.displayName).modifier(SidebarItemLabelTextModifier())

                    Spacer()

                    if editMode?.wrappedValue == .inactive {
                        if viewModel.refreshing {
                            ProgressView().progressViewStyle(IconProgressStyle())
                        } else {
                            Text(String(viewModel.page.previewItems.unread().count))
                                .modifier(CapsuleModifier())
                        }
                    }
                }.lineLimit(1)
            } icon: {
                Image(systemName: viewModel.page.wrappedSymbol).imageScale(.large)
            }
        }
        .accessibilityIdentifier("page-button")
    }
}
