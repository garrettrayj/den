//
//  GlobalView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct GlobalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var linkManager: LinkManager
    @EnvironmentObject private var profileManager: ProfileManager

    @ObservedObject var viewModel: GlobalViewModel

    @State private var showingSettings: Bool = false

    @AppStorage("globalViewMode") var viewMode = 0
    @AppStorage("globalHideRead") var hideRead = false

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
                            if viewMode == ContentViewMode.trends.rawValue {
                                GlobalTrendsView(profile: viewModel.profile, frameSize: geometry.size)
                            } else if viewMode == ContentViewMode.timeline.rawValue {
                                GlobalTimelineView(
                                    profile: viewModel.profile,
                                    hideRead: $hideRead,
                                    frameSize: geometry.size
                                )
                            } else if viewMode == ContentViewMode.showcase.rawValue {
                                GlobalShowcaseView(
                                    profile: viewModel.profile,
                                    hideRead: $hideRead,
                                    frameSize: geometry.size
                                )
                            } else {
                                GlobalGadgetsView(
                                    profile: viewModel.profile,
                                    hideRead: $hideRead,
                                    frameSize: geometry.size
                                )
                            }
                        }.padding(.top, 8)
                    }
                }
            }
        }
        .onChange(of: viewMode, perform: { _ in
            viewModel.objectWillChange.send()
        })
        .background(Color(UIColor.systemGroupedBackground))
        .navigationTitle("All Feeds")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { toolbarContent }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if targetEnvironment(macCatalyst)
        ToolbarItem(placement: .navigationBarTrailing) {
            ContentModePickerView(viewMode: $viewMode)
                .padding(.trailing, 8)
                .pickerStyle(.inline)
        }

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
                    ContentModePickerView()

                    Button {
                        subscriptionManager.showSubscribe()
                    } label: {
                        Label("Add Feed", systemImage: "plus.circle")
                    }.accessibilityIdentifier("add-feed-button")

                    Button {
                        showingSettings = true
                    } label: {
                        Label("Page Settings", systemImage: "wrench")
                    }.accessibilityIdentifier("page-settings-button")
                } label: {
                    Label("Page Menu", systemImage: "ellipsis.circle").font(.body.weight(.medium))
                }
                .accessibilityIdentifier("page-menu")
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
