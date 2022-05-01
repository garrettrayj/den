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
                        BackButtonView(title: viewModel.feed.page?.displayName ?? "Back")
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        if viewModel.refreshing {
                            ProgressView().progressViewStyle(ToolbarProgressStyle())
                        } else {
                            Button {
                                showingSettings = true
                            } label: {
                                Label("Feed Settings", systemImage: "wrench")
                            }
                            .disabled(viewModel.refreshing)
                            .accessibilityIdentifier("feed-settings-button")
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
