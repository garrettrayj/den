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
    @ObservedObject var pageViewModel: PageViewModel
    
    let columns = [
        GridItem(.adaptive(minimum: 320, maximum: 560), spacing: 16, alignment: .top)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if pageViewModel.page.isDeleted {
                    Text("Page Deleted")
                        .font(.title)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .navigationTitle("")
                } else {
                    ZStack(alignment: .top) {
                        if pageViewModel.page.feedsArray.count > 0 {
                            dashboardModeContent
                        } else {
                            Text("Page Empty").font(.title).foregroundColor(.secondary).frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        }
                    }
                    .sheet(item: $pageViewModel.pageSheetViewModel) { pageSheet in
                        if pageSheet.modal == .organizer {
                            PageSettingsView(page: self.pageViewModel.page)
                                .environment(\.managedObjectContext, self.viewContext)
                        } else if pageSheet.modal == .options {
                            FeedWidgetOptionsView(feed: pageSheet.feed!)
                                .environment(\.managedObjectContext, self.viewContext)
                                .environmentObject(self.refreshManager)
                        }
                    }
                    .navigationTitle(Text(pageViewModel.page.name ?? "Page Deleted"))
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(trailing: trailingNavigationBarItems)
                }
            }
            .padding(.top, geometry.safeAreaInsets.top)
            .onAppear(perform: checkRefresh)
            .background(Color(.secondarySystemBackground))
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    var dashboardModeContent: some View {
        VStack {
            HeaderProgressBarView(page: pageViewModel.page)
            
            RefreshableScrollView(page: pageViewModel.page) {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(pageViewModel.page.feedsArray, id: \.self) { feed in
                        FeedWidgetView(feed: feed, pageSheetViewModel: $pageViewModel.pageSheetViewModel)
                    }
                }
                .padding(16)
            }
        }
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
    
    func checkRefresh() {
        self.screenManager.currentPage = pageViewModel.page
        if let lastRefreshed = pageViewModel.page.minimumRefreshedDate {
            if Date() - lastRefreshed > TimeInterval(7200) {
                refreshManager.refresh(pageViewModel.page)
            }
        } else {
            // Initial feed load
            refreshManager.refresh(pageViewModel.page)
        }
    }
    
    private func calcGridTracks(_ availableWidth: CGFloat) -> Tracks {
        if availableWidth > 2000 {
            return Tracks.min(400)
        }
        
        return Tracks.min(320)
    }
}
