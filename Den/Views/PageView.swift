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
    @ObservedObject var page: Page
    @State var activeSheet: PageSheetViewModel?
    @State var showingPageMenu: Bool = false
    
    let columns = [
        GridItem(.adaptive(minimum: 320, maximum: 560), spacing: 20, alignment: .top)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if page.name == nil {
                Text("Page Deleted")
                    .font(.title)
                    .foregroundColor(.secondary)
                    .navigationBarTitle("")
                    .navigationBarItems(trailing: EmptyView())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 0) {
                    if self.page.feedsArray.count > 0 {
                        if self.refreshManager.isRefreshing([self.page]) {
                            HeaderProgressBarView(refreshables: [self.page])
                        }
                        
                        RefreshableScrollView(refreshables: [self.page]) {
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(self.page.feedsArray) { feed in
                                    FeedWidgetView(feed: feed, activeSheet: $activeSheet)
                                }
                            }
                            .padding(20)
                        }
                    } else {
                        Text("Empty Page").font(.title).foregroundColor(.secondary).frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .sheet(item: $activeSheet) { pageSheet in
                    if pageSheet.state == .organizer {
                        PageOrganizerView(page: self.page).environment(\.managedObjectContext, self.viewContext)
                    } else if pageSheet.state == .options {
                        FeedWidgetOptionsView(feed: pageSheet.feed!)
                            .environment(\.managedObjectContext, self.viewContext)
                            .environmentObject(self.refreshManager)
                    }
                }
                .navigationBarTitle(Text(page.name ?? "Page Deleted"), displayMode: .inline)
                .navigationBarItems(
                    trailing: HStack(alignment: .center, spacing: 0) {
                        Button(action: showMenu) {
                            Image(systemName: "ellipsis").titleBarIconView()
                        }
                        .disabled(refreshManager.refreshing)
                        .actionSheet(isPresented: $showingPageMenu) {
                            ActionSheet(title: Text("Page Menu"), message: nil, buttons: [
                                .default(Text("Refresh")) { self.refreshManager.refresh([self.page]) },
                                .default(Text("Add Feed")) { self.showSubscribe() },
                                .default(Text("Page Settings")) { self.showOrganizer() },
                                .cancel()
                            ])
                        }
                    }.offset(x: 12)
                )
            }
        }
        .padding(.top, 1)
        .onAppear {
            self.screenManager.currentPage = self.page
        }
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea([.horizontal, .bottom])
    }
    
    func showMenu() {
        self.showingPageMenu = true
    }
    
    func showOrganizer() {
        self.activeSheet = PageSheetViewModel(state: .organizer)
    }
    
    func showSubscribe() {
        self.screenManager.subscribe()
    }
    
    private func calcGridTracks(_ availableWidth: CGFloat) -> Tracks {
        if availableWidth > 2000 {
            return Tracks.min(400)
        }
        
        return Tracks.min(320)
    }
}
