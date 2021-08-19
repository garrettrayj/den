//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var refreshManager: RefreshManager
    @ObservedObject var page: Page

    @State private var showingSettings: Bool = false

    let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16, alignment: .top)
    ]

    var body: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: PageSettingsView(page: page), isActive: $showingSettings) {
                Label("Page Settings", systemImage: "wrench")
            }.hidden().frame(height: 0)

            if page.managedObjectContext == nil {
                pageDeleted
            } else if page.feedsArray.count == 0 {
                pageEmpty
            } else {
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        RefreshableScrollView(page: page) {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(page.feedsArray, id: \.self) { feed in
                                    FeedWidgetView(feed: feed)
                                }
                            }
                            .padding(.leading, horizontalInset(geometry.safeAreaInsets.leading))
                            .padding(.trailing, horizontalInset(geometry.safeAreaInsets.trailing))
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                        }
                        HeaderProgressBarView()
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                }
            }
        }
        .navigationTitle(Text(page.displayName))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { pageToolbar }
        .onAppear {
            subscriptionManager.destinationPage = page
        }
        .background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all))
    }

    private var pageToolbar: some ToolbarContent {
        ToolbarItemGroup {
            if page.managedObjectContext != nil {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    // Action menu for phone users
                    Menu {
                        Button(action: showSubscribe) {
                            Label("Add Subscription", systemImage: "plus.circle")
                        }

                        Button(action: showSettings) {
                            Label("Page Settings", systemImage: "wrench")
                        }

                        Button { refreshManager.refresh(page: self.page) } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Label("Page Menu", systemImage: "ellipsis")
                            .frame(height: 44)
                            .padding(.leading)
                    }.disabled(refreshManager.refreshing == true)
                } else {
                    // Show three buttons on larger screens
                    HStack(spacing: 16) {
                        Button(action: showSubscribe) {
                            Label("Add Subscription", systemImage: "plus.circle")
                        }

                        Button(action: showSettings) {
                            Label("Page Settings", systemImage: "wrench")
                        }

                        Button { refreshManager.refresh(page: self.page) } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    }
                    .disabled(refreshManager.refreshing == true)
                    .buttonStyle(ActionButtonStyle())

                }
            }
        }
    }

    private var pageEmpty: some View {
        Text("Page Empty")
            .font(.title)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var pageDeleted: some View {
        Text("Page Deleted")
            .font(.title)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .navigationTitle("")
    }

    private func showSettings() {
        showingSettings = true
    }

    private func showSubscribe() {
        subscriptionManager.showAddSubscription()
    }

    private func horizontalInset(_ safeArea: CGFloat) -> CGFloat {
        if safeArea > 0 {
            return safeArea
        }

        return 16
    }
}
