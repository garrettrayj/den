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
    @EnvironmentObject private var linkManager: LinkManager

    @ObservedObject var viewModel: FeedViewModel

    @State var showingSettings: Bool = false

    @AppStorage("feedHideRead_na") var hideRead = false

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel

        _hideRead = AppStorage(
            wrappedValue: false,
            "feedHideRead_\(viewModel.feed.id?.uuidString ?? "na")"
        )
    }

    var body: some View {
        Group {
            if viewModel.feed.managedObjectContext == nil {
                StatusBoxView(message: Text("Feed Deleted"), symbol: "slash.circle")
                    .navigationTitle("")
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        FeedItemsView(feed: viewModel.feed, hideRead: $hideRead, frameSize: geometry.size)
                    }
                }
                .toolbar { toolbar }
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .background(
            NavigationLink(
                destination: FeedSettingsView(
                    viewModel: FeedSettingsViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager,
                        feed: viewModel.feed
                    )
                ),
                isActive: $showingSettings
            ) {
                EmptyView()
            }
        )
        .onChange(of: viewModel.feed.page) { _ in
            dismiss()
        }
        .navigationTitle(viewModel.feed.wrappedTitle)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
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

        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                withAnimation {
                    hideRead.toggle()
                }
            } label: {
                Label(
                    "Filter Read",
                    systemImage: hideRead ?
                        "line.3.horizontal.decrease.circle.fill"
                        : "line.3.horizontal.decrease.circle"
                )
            }
            Spacer()
            VStack {
                Text("\(viewModel.feed.feedData?.unreadItems.count ?? 0) Unread").font(.caption)
            }
            Spacer()
            Button {
                // Toggle all read/unread
                if viewModel.feed.feedData?.unreadItems.isEmpty == true {
                    linkManager.markAllUnread(feed: viewModel.feed)
                    viewModel.feed.feedData?.limitedItemsArray.forEach { item in
                        item.objectWillChange.send()
                    }
                } else {
                    linkManager.markAllRead(feed: viewModel.feed)
                    viewModel.feed.feedData?.limitedItemsArray.forEach { item in
                        item.objectWillChange.send()
                    }
                }
            } label: {
                Label(
                    "Mark All Read",
                    systemImage: viewModel.feed.feedData?.unreadItems.isEmpty ?? false ?
                        "checkmark.circle.fill" : "checkmark.circle"
                )
            }
            .accessibilityIdentifier("mark-all-read-button")
            .disabled(viewModel.refreshing)
        }

    }
}
