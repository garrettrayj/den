//
//  SidebarPageView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPageView: View {
    @Environment(\.editMode) var editMode
    @ObservedObject var viewModel: PageViewModel

    var body: some View {
        Label(
            title: {
                HStack {
                    Text(viewModel.page.displayName)
                        #if targetEnvironment(macCatalyst)
                        .padding(.vertical, 6)
                        .padding(.leading, 8)
                        .font(.title3)
                        #endif

                    Spacer()

                    Group {
                        if editMode?.wrappedValue == .inactive {
                            if viewModel.refreshing {
                                ProgressView().progressViewStyle(IconProgressStyle())
                            } else {
                                Text(String(viewModel.page.unreadCount))
                                    .font(.caption.weight(.medium))
                                    .foregroundColor(Color(UIColor.secondaryLabel))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .overlay(
                                        Capsule().fill(Color(UIColor.secondarySystemFill))
                                    )
                            }
                        }
                    }
                    #if !targetEnvironment(macCatalyst)
                    .padding(.trailing, 4)
                    #endif

                }.lineLimit(1)
            },
            icon: { Image(systemName: viewModel.page.wrappedSymbol).imageScale(.medium) }
        ).background(
            NavigationLink(destination: {
                PageView(viewModel: viewModel)
            }, label: {
                EmptyView()
            }).opacity(0)
        )
    }
}
