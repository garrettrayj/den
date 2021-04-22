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
    @ObservedObject var pageViewModel: PageViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 320, maximum: 560), spacing: 16, alignment: .top)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if pageViewModel.page.managedObjectContext == nil {
                    pageDeleted
                } else {
                    ZStack(alignment: .top) {
                        if pageViewModel.hasSubscriptions() {
                            dashboardMode
                        } else {
                            pageEmpty
                        }
                    }
                    .sheet(item: $pageViewModel.pageSheetViewModel) { pageSheet in
                        if pageSheet.modal == .organizer {
                            PageSettingsView(page: pageViewModel.page)
                                .environment(\.managedObjectContext, viewContext)
                                .environmentObject(refreshManager)
                                .environmentObject(crashManager)
                        } else if pageSheet.modal == .options {
                            FeedWidgetOptionsView(subscription: pageSheet.subscription!)
                                .environment(\.managedObjectContext, viewContext)
                                .environmentObject(refreshManager)
                                .environmentObject(crashManager)
                        }
                    }
                    .navigationTitle(Text(pageViewModel.page.name ?? "Page Deleted"))
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing: trailingNavigationBarItems)
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
            RefreshableScrollView(page: pageViewModel.page) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(pageViewModel.page.subscriptionsArray, id: \.self) { subscription in
                        FeedWidgetView(subscription: subscription, pageSheetViewModel: $pageViewModel.pageSheetViewModel)
                    }
                }
                .padding(16)
            }
            
            HeaderProgressBarView(page: pageViewModel.page)
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
            Button(action: showMenu) {
                Image(systemName: "ellipsis").titleBarIconView()
            }
            .disabled(refreshManager.refreshing)
            .actionSheet(isPresented: $pageViewModel.showingMenu) {
                ActionSheet(title: Text("Page Menu"), message: nil, buttons: [
                    .default(Text("Refresh Feeds")) { self.refreshManager.refresh(self.pageViewModel.page) },
                    .default(Text("Add Subscription")) { self.showSubscribe() },
                    .default(Text("Page Settings")) { self.showOrganizer() },
                    .cancel()
                ])
            }
        }.offset(x: 12)
    }
    
    func showMenu() {
        self.pageViewModel.showingMenu = true
    }
    
    func showOrganizer() {
        self.pageViewModel.pageSheetViewModel = PageSheetViewModel(modal: .organizer)
    }
    
    func showSubscribe() {
        self.screenManager.subscribe()
    }
    
    func onAppear() {
        self.screenManager.currentPage = pageViewModel.page
        
        if pageViewModel.page.minimumRefreshedDate == nil {
            refreshManager.refresh(pageViewModel.page)
        }
    }
}
