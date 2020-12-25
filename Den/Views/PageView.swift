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
    @State var activeSheet: PageSheet?
    @State var showingPageMenu: Bool = false
    
    let columns = [
        GridItem(.adaptive(minimum: 320, maximum: 520), spacing: 20, alignment: .top)
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
                                    FeedView(feed: feed, activeSheet: $activeSheet)
                                }
                            }
                            .padding()
                        }
                    } else {
                        Text("Empty Page").font(.title).foregroundColor(.secondary).frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .sheet(item: $activeSheet) { pageSheet in
                    if pageSheet.state == .organizer {
                        PageOrganizerView(page: self.page).environment(\.managedObjectContext, self.viewContext)
                    } else if pageSheet.state == .options {
                        FeedEditView(feed: pageSheet.feed!)
                            .environment(\.managedObjectContext, self.viewContext)
                            .environmentObject(self.refreshManager)
                    }
                }
                .navigationBarTitle(Text(page.name ?? "Page Deleted"), displayMode: .inline)
                .navigationBarItems(
                    trailing: HStack(alignment: .center, spacing: 0) {
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            // Action menu for phone users
                            Button(action: showMenu) {
                                Image(systemName: "hammer").titleBarIconView()
                            }
                            .disabled(refreshManager.refreshing)
                            .actionSheet(isPresented: $showingPageMenu) {
                                ActionSheet(title: Text("Page Actions"), message: nil, buttons: [
                                    .default(Text("Refresh")) { self.refreshManager.refresh([self.page]) },
                                    .default(Text("Organize")) { self.showOrganizer() },
                                    .default(Text("Add Feed")) { self.showSubscribe() },
                                    .cancel()
                                ])
                            }
                        } else {
                            // Just show three buttons on larger screens
                            Button(action: showSubscribe) {
                                Image(systemName: "plus").titleBarIconView()
                            }
                            Button(action: showOrganizer) {
                                Image(systemName: "arrow.up.arrow.down").titleBarIconView()
                            }
                            Button(action: { self.refreshManager.refresh([self.page]) }) {
                                Image(systemName: "arrow.clockwise").titleBarIconView()
                            }.disabled(refreshManager.refreshing)
                        }
                    }.offset(x: 12).font(.body)
                )
            }
        }
        .padding(.top, 1)
        .onAppear {
            self.screenManager.currentPage = self.page
        }
        .background(Color(UIColor.secondarySystemBackground))
        .edgesIgnoringSafeArea([.horizontal, .bottom])
    }
    
    func showMenu() {
        self.showingPageMenu = true
    }
    
    func showOrganizer() {
        self.activeSheet = PageSheet(state: .organizer)
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
