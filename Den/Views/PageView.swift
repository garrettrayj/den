//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscribeManager: SubscribeManager

    @ObservedObject var viewModel: PageViewModel
    @State var showingSettings: Bool = false

    let columns = [GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 16, alignment: .top)]
    let pageDeleted = NotificationCenter.default.publisher(for: .pageDeleted)

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.page.managedObjectContext == nil {
                pageRemoved
            } else if viewModel.page.feedsArray.count == 0 {
                pageEmpty
            } else {
                #if targetEnvironment(macCatalyst)
                ScrollView {
                    widgetGrid
                }
                #else
                RefreshableScrollView(
                    state: $viewModel.refreshState,
                    onRefresh: { done in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            done()
                        }
                    },
                    content: { widgetGrid }
                )
                #endif
            }
        }
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .background(NavigationLink(
            destination: PageSettingsView(page: viewModel.page),
            isActive: $showingSettings
        ) {
            Text("Show Settings")
        })
        .navigationTitle(viewModel.page.displayName)
        .toolbar { toolbar }
        .onAppear {
            subscribeManager.currentPageId = viewModel.page.id?.uuidString
        }
        .onReceive(pageDeleted) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        }
    }

    private var widgetGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.page.feedsArray) { feed in
                FeedWidgetView(feed: feed)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 64)
    }

    private var toolbar: some ToolbarContent {
        ToolbarItemGroup {
            if viewModel.page.managedObjectContext != nil {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    compactToolbar.disabled(viewModel.refreshState == .loading)
                } else {
                    fullToolbar.disabled(viewModel.refreshState == .loading)
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

            Button {
                refreshManager.refresh(pageViewModel: viewModel)
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }.keyboardShortcut("r", modifiers: [.command])
        } label: {
            Label("Page Menu", systemImage: "ellipsis")
                .frame(height: 44)
                .padding(.horizontal, 12)
                .background(Color.clear)
        }
    }

    private var fullToolbar: some View {
        HStack(spacing: 0) {
            Button(action: showSubscribe) {
                Label("Add Subscription", systemImage: "plus.circle")
            }

            Button(action: showSettings) {
                Label("Page Settings", systemImage: "wrench")
            }

            if viewModel.refreshState == .loading {
                ProgressView(value: 0).progressViewStyle(ToolbarProgressStyle())
            } else {
                Button {
                    refreshManager.refresh(pageViewModel: viewModel)
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }.keyboardShortcut("r", modifiers: [.command])
            }
        }.buttonStyle(ToolbarButtonStyle())
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
