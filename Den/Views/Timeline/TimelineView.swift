//
//  TimelineView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TimelineView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var linkManager: LinkManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var viewModel: TimelineViewModel

    @AppStorage("timelineHideRead") var hideRead = false

    #if targetEnvironment(macCatalyst)
    let emptyCaption = Text("""
    Add feeds by opening syndication links \
    or click \(Image(systemName: "plus.circle")) to add by web address
    """)
    #else
    let emptyCaption = Text("""
    Add feeds by opening syndication links \
    or tap \(Image(systemName: "ellipsis.circle")) then \(Image(systemName: "plus.circle")) \
    to add by web address
    """)
    #endif

    var body: some View {
        VStack {
            if viewModel.profile.feedsArray.isEmpty {
                StatusBoxView(
                    message: Text("Page Empty"),
                    caption: emptyCaption,
                    symbol: "questionmark.square.dashed"
                )
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        Group {
                            if viewModel.profile.previewItems.isEmpty {
                                StatusBoxView(message: Text("Timeline Empty"), symbol: "clock")
                            } else {
                                BoardView(width: geometry.size.width, list: visibleItems) { item in
                                    FeedItemPreviewView(item: item)
                                }
                                .padding()
                            }
                        }.padding(.top, 8)
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
    }

    private var visibleItems: [Item] {
        viewModel.profile.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if targetEnvironment(macCatalyst)
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                subscriptionManager.showSubscribe()
            } label: {
                Label("Add Feed", systemImage: "plus.circle")
            }
            .accessibilityIdentifier("add-feed-button")
        }

        #else
        ToolbarItem {
            if viewModel.refreshing {
                ProgressView()
                    .progressViewStyle(ToolbarProgressStyle())
            } else {
                Menu {
                    Button {
                        subscriptionManager.showSubscribe()
                    } label: {
                        Label("Add Feed", systemImage: "plus.circle")
                    }.accessibilityIdentifier("add-feed-button")
                } label: {
                    Label("Timeline Menu", systemImage: "ellipsis.circle").font(.body.weight(.medium))
                }
                .accessibilityIdentifier("timeline-menu")
            }
        }
        #endif

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
                Text("\(viewModel.profile.previewItems.unread().count) Unread").font(.caption)
            }
            Spacer()
            Button {
                linkManager.toggleReadUnread(profile: viewModel.profile)
                dispatchItemChanges()
            } label: {
                Label(
                    "Mark All Read",
                    systemImage: viewModel.profile.previewItems.unread().isEmpty ?
                        "checkmark.circle.fill" : "checkmark.circle"
                )
            }
            .accessibilityIdentifier("mark-all-read-button")
            .disabled(viewModel.refreshing)
        }
    }

    private func dispatchItemChanges() {
        DispatchQueue.main.async {
            viewModel.profile.previewItems.forEach { item in
                item.objectWillChange.send()
            }
            viewModel.objectWillChange.send()
        }
    }
}
