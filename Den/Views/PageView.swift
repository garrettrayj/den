//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscribeManager: SubscribeManager

    @ObservedObject var page: Page

    @State var showingSettings: Bool = false
    @Binding var refreshing: Bool

    let columns = [GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16, alignment: .top)]

    var body: some View {
        VStack(spacing: 0) {
            if page.managedObjectContext == nil {
                pageRemoved
            } else if page.feedsArray.count == 0 {
                pageEmpty
            } else {
                #if targetEnvironment(macCatalyst)
                ScrollView {
                    widgetGrid
                }
                #else
                RefreshableScrollView(
                    refreshing: $refreshing,
                    onRefresh: { _ in
                        refresh()
                    },
                    content: { widgetGrid }
                )
                #endif
            }
        }
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .background(
            Group {
                NavigationLink(
                    destination: PageSettingsView(page: page),
                    isActive: $showingSettings
                ) {
                    Text("Show Settings")
                }

                // Hidden button for iOS keyboard shortcut
                #if !targetEnvironment(macCatalyst)
                Button(action: refresh, label: { Text("Refresh") })
                    .keyboardShortcut("r", modifiers: [.command])
                #endif
            }
        )
        .navigationTitle(page.displayName)
        .toolbar { toolbar }
        .onAppear {
            subscribeManager.currentPageId = page.id?.uuidString
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .pageDeleted, object: page.objectID)
        ) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        }
    }

    private var widgetGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(page.feedsArray) { feed in
                GadgetView(feed: feed, refreshing: refreshing)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 64)
    }

    private var pageEmpty: some View {
        Group {
            if UIDevice.current.userInterfaceIdiom == .phone {
                Text("Tap \(Image(systemName: "ellipsis.circle")) to add a subscription")
                    .modifier(SimpleMessageModifier())
            } else {
                Text("Tap \(Image(systemName: "plus.circle")) to add a subscription")
                    .modifier(SimpleMessageModifier())
            }
        }
    }

    private var pageRemoved: some View {
        Text("This page no longer exists")
            .modifier(SimpleMessageModifier())
            .navigationTitle("Page Removed")
    }

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup {
            if page.managedObjectContext != nil {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    compactToolbar.disabled(refreshing)
                } else {
                    fullToolbar.disabled(refreshing)
                }
            }
        }
    }

    private var compactToolbar: some View {
        Menu {
            Button(action: showSubscribe) {
                Label("Add Subscription", systemImage: "plus.circle")
            }

            Button(action: showSettings) {
                Label("Page Settings", systemImage: "wrench")
            }
        } label: {
            Label("Page Menu", systemImage: "ellipsis")
                .frame(height: 44)
                .padding(.horizontal, 12)
                .background(Color.clear)
        }
    }

    private var fullToolbar: some View {
        Group {
            Button(action: showSubscribe) {
                Label("Add Subscription", systemImage: "plus.circle")
            }

            Button(action: showSettings) {
                Label("Page Settings", systemImage: "wrench")
            }

            #if targetEnvironment(macCatalyst)
            Button(action: refresh) {
                if refreshing {
                    ProgressView().progressViewStyle(ToolbarProgressStyle())
                } else {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }.keyboardShortcut("r", modifiers: [.command])
            #endif
        }
        .buttonStyle(ToolbarButtonStyle())
    }

    private func refresh() {
        refreshManager.refresh(pages: [page])
    }

    private func showSettings() {
        showingSettings = true
    }

    private func showSubscribe() {
        subscribeManager.showAddSubscription()
    }

    private func horizontalInset(_ safeArea: CGFloat) -> CGFloat {
        if safeArea > 0 {
            return safeArea
        }

        return 16
    }
}
