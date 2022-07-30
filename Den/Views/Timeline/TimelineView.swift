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

    @AppStorage("hideRead") var hideRead = false

    var body: some View {
        GeometryReader { geometry in
            if viewModel.profile.feedsArray.isEmpty {
                NoFeedsView()
            } else if viewModel.profile.previewItems.isEmpty {
                NoItemsView()
            } else {
                ScrollView(.vertical) {
                    TimelineItemsView(profile: viewModel.profile, hideRead: $hideRead, frameSize: geometry.size)
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
        .onAppear { viewModel.objectWillChange.send() }
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

        ReadingToolbarContent(
            items: viewModel.profile.previewItems,
            disabled: viewModel.refreshing,
            hideRead: $hideRead
        ) {
            linkManager.toggleReadUnread(profile: viewModel.profile)
            dispatchItemChanges()
        } filterAction: {
            withAnimation {
                hideRead.toggle()
            }
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
