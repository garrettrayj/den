//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var viewModel: FeedViewModel

    @State var showingSettings: Bool = false

    var body: some View {
        Group {
            if viewModel.feed.managedObjectContext == nil {
                StatusBoxView(message: Text("Feed Deleted"), symbol: "slash.circle")
                    .navigationTitle("")
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) { FeedItemsView(feed: viewModel.feed, frameSize: geometry.size) }
                }
                .navigationBarBackButtonHidden(true)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { dismiss() } label: {
                            Label(viewModel.feed.page?.displayName ?? "Back", systemImage: "chevron.backward")
                                .labelStyle(.titleAndIcon)
                        }
                        .buttonStyle(ToolbarButtonStyle())
                        .modifier(ToolbarItemOffsetModifier(alignment: .leading))
                    }

                    ToolbarItem {
                        if viewModel.refreshing {
                            ProgressView()
                                .progressViewStyle(ToolbarProgressStyle())
                                .modifier(ToolbarItemOffsetModifier())
                        } else {
                            Button {
                                showingSettings = true
                            } label: {
                                Label("Feed Settings", systemImage: "wrench")
                            }
                            .buttonStyle(ToolbarButtonStyle())
                            .disabled(viewModel.refreshing)
                            .accessibilityIdentifier("feed-settings-button")
                            .modifier(ToolbarItemOffsetModifier())
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .background(
            NavigationLink(
                destination: FeedSettingsView(viewModel: FeedSettingsViewModel(
                    viewContext: viewContext, crashManager: crashManager, feed: viewModel.feed
                )),
                isActive: $showingSettings
            ) {
                EmptyView()
            }
        )
        .navigationTitle(viewModel.feed.wrappedTitle)

    }
}
