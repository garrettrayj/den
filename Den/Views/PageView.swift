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
                    ZStack(alignment: .top) {
                        if page.subscriptions?.count ?? 0 > 0 {
                            dashboardMode
                        } else {
                            pageEmpty
                        }
                    }
                }
            }
            .navigationTitle(Text(page.wrappedName))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: trailingNavigationBarItems)
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
                }
                .padding(16)
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
    
    var trailingNavigationBarItems: some View {
        HStack(alignment: .center, spacing: 0) {
            Button(action: { refreshManager.refresh(self.page) }) {
                Image(systemName: "arrow.clockwise").titleBarIconView()
            }
            
            Button(action: showSubscribe) {
                Image(systemName: "plus.circle").titleBarIconView()
            }
            
            Button(action: showOrganizer) {
                Image(systemName: "wrench").titleBarIconView()
            }
        }.offset(x: 12)
    }
    
    func showOrganizer() {
        mainViewModel.pageSheetMode = .organizer
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
