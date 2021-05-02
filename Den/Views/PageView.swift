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
    @EnvironmentObject var screenManager: SubscriptionManager
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var crashManager: CrashManager
    @ObservedObject var mainViewModel: MainViewModel
    @ObservedObject var page: Page
    
    let columns = [
        GridItem(.adaptive(minimum: 320, maximum: 560), spacing: 16, alignment: .top)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if page.managedObjectContext == nil {
                    pageDeleted
                } else {
                    if page.subscriptions?.count ?? 0 > 0 {
                        dashboardMode
                    } else {
                        pageEmpty
                    }
                }
            }
            .actionSheet(isPresented: $mainViewModel.showingPageMenu) {
                ActionSheet(title: Text("Page"), message: nil, buttons: [
                    .default(Text("Refresh")) { self.refreshManager.refresh(self.page) },
                    .default(Text("Page Preferences")) { self.showSettings() },
                    .default(Text("Add Subscription")) { self.showSubscribe() },
                    .cancel()
                ])
            }
            .navigationTitle(Text(page.wrappedName))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar() {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        // Action menu for phone users
                        Button(action: showMenu) {
                            Image(systemName: "ellipsis")
                        }
                        .disabled(refreshManager.refreshing)
                        
                    } else {
                        // Show three buttons on larger screens
                        Button(action: { refreshManager.refresh(self.page) }) {
                            Image(systemName: "arrow.clockwise")
                        }.accessibility(hint: Text("Refresh"))
                        
                        Button(action: showSubscribe) {
                            Image(systemName: "plus.circle")
                        }.accessibility(hint: Text("Add Subscription"))
                        
                        Button(action: showSettings) {
                            Image(systemName: "wrench")
                        }.accessibility(hint: Text("Page Preferences"))
                    }
                }
            }
            
            .padding(.top, geometry.safeAreaInsets.top)
            .onAppear(perform: onAppear)
            .background(Color(.secondarySystemBackground))
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    var dashboardMode: some View {
        ZStack(alignment: .top) {
            RefreshableScrollView(page: page) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(page.subscriptionsArray, id: \.self) { subscription in
                        FeedWidgetView(subscription: subscription, mainViewModel: mainViewModel)
                    }
                }.padding([.top, .horizontal], 16).padding(.bottom, 64)
            }
            
            HeaderProgressBarView(page: page)
        }
    }
    
    var pageEmpty: some View {
        Text("Page Empty")
            .font(.title)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
    
    var pageDeleted: some View {
        Text("Page Deleted")
            .font(.title)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .navigationTitle("")
    }
    
    func showMenu() {
        mainViewModel.showingPageMenu = true
    }
    
    func showSettings() {
        mainViewModel.pageSheetMode = .pageSettings
        mainViewModel.showingPageSheet = true
    }
    
    func showSubscribe() {
        mainViewModel.pageSheetMode = .subscribe
        mainViewModel.showingPageSheet = true
    }
    
    func onAppear() {
        self.mainViewModel.activePage = page
        
        if page.minimumRefreshedDate == nil {
            refreshManager.refresh(page)
        }
    }
}
