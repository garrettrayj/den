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
    @ObservedObject var page: Page
    @Binding var refreshing: Bool

    var body: some View {
        NavigationLink {
            PageView(page: page, refreshing: $refreshing)
        } label: {
            Label {
                HStack {
                    Text(page.displayName).modifier(SidebarItemLabelTextModifier())

                    Spacer()

                    if editMode?.wrappedValue == .inactive {
                        if refreshing {
                            ProgressView().progressViewStyle(IconProgressStyle())
                        } else {
                            Text(String(page.previewItems.unread().count))
                                .modifier(CapsuleModifier())
                        }
                    }
                }.lineLimit(1)
            } icon: {
                Image(systemName: page.wrappedSymbol).imageScale(.large)
            }
        }
        .accessibilityIdentifier("page-button")
    }
}
