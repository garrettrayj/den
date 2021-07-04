//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import Grid

/**
 Grid layout of Feed views. Hosts sheets for editing and organizing feeds, subscribing to new feeds.
 */
struct PageView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager
    @ObservedObject var page: Page
    
    @State private var showingSettings: Bool = false
    
    
    let columns = [
        GridItem(.adaptive(minimum: 360, maximum: 480), spacing: 16, alignment: .top)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if page.managedObjectContext == nil {
                pageDeleted
            } else if page.feedsArray.count == 0 {
                pageEmpty
            } else {
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        NavigationLink(destination: PageSettingsView(page: page), isActive: $showingSettings) {
                            Label("Page Settings", systemImage: "wrench")
                        }.hidden()
                        
                        RefreshableScrollView(page: page) {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(page.feedsArray, id: \.self) { feed in
                                    FeedWidgetView(feed: feed)
                                }
                            }
                            .padding(.leading, geometry.safeAreaInsets.leading + 16)
                            .padding(.trailing, geometry.safeAreaInsets.trailing + 16)
                            .padding(.top, 16)
                            .padding(.bottom, 64)
                        }
                        HeaderProgressBarView(page: page)
                    }
                }
            }
        }
        .navigationTitle(Text(page.wrappedName))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup {
                if UIDevice.current.userInterfaceIdiom == .phone {
                    // Action menu for phone users
                    Menu {
                        Button(action: showSubscribe) {
                            Label("Add Subscription", systemImage: "plus.circle")
                        }
                        
                        Button(action: showSettings) {
                            Label("Page Settings", systemImage: "wrench")
                        }
                        
                        Button(action: { refreshManager.refresh(self.page) }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                    } label: {
                        Label("Page Menu", systemImage: "ellipsis")
                            .frame(height: 44)
                            .padding(.leading)
                    }.disabled(refreshManager.refreshing == true)
                } else {
                    // Show three buttons on larger screens
                    Button(action: showSubscribe) {
                        Label("Add Subscription", systemImage: "plus.circle")
                    }.disabled(refreshManager.refreshing == true)
                    
                    Button(action: showSettings) {
                        Label("Page Settings", systemImage: "wrench")
                    }.disabled(refreshManager.refreshing == true)
                    
                    Button(action: { refreshManager.refresh(self.page) }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }.disabled(refreshManager.refreshing == true)
                }
            }
        }
        .onAppear(perform: onAppear)
        .background(Color(.secondarySystemBackground).edgesIgnoringSafeArea(.all))
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
    
    private func onAppear() {
        subscriptionManager.destinationPage = page
        
        if page.minimumRefreshedDate == nil {
            refreshManager.refresh(page)
        }
    }
}
