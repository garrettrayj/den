//
//  PageListRowView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageListRowView: View {
    @Environment(\.editMode) var editMode

    @ObservedObject var page: Page

    var body: some View {
        if page.id != nil {
            if editMode?.wrappedValue == .inactive {
                NavigationLink(
                    destination: PageView(viewModel: PageViewModel(page: page))
                ) {
                    HStack {
                        Label(page.displayName, systemImage: page.wrappedSymbol)
                            .lineLimit(1)
                            .foregroundColor(.primary)
                            .padding(.vertical, 4)

                        Spacer()

                        Text(String(page.unreadCount))
                            .lineLimit(1)
                            .font(.caption)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                Capsule(style: .circular)
                                    .foregroundColor(Color(.systemGroupedBackground))
                            )
                    }
                }
            } else {
                Text(page.wrappedName)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 4)
            }
        }
    }
}
