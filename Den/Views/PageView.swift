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
    enum PageSheet {
        case organizer, feedEdit, subscribe
    }
    
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var screenManager: SubscriptionManager
    @EnvironmentObject var refreshManager: RefreshManager
    @ObservedObject var page: Page
    @State var showingSheet: Bool = false
    @State var activeSheet: PageSheet = .organizer
    @State var editingFeed: Feed?
    @State var showingActionSheet: Bool = false
    
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
                        
                        GeometryReader { geometry in
                            RefreshableScrollView(refreshables: [self.page]) {
                                Grid(self.page.feedsArray) { feed in
                                    FeedView(feed: feed, parent: self)
                                }
                                .gridStyle(StaggeredGridStyle(availableWidth: geometry.size.width))
                                .padding()
                                .padding(.bottom, 64)
                            }
                        }
                    } else {
                        Text("Empty Page").font(.title).foregroundColor(.secondary).frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                .sheet(isPresented: self.$showingSheet) {
                    if self.activeSheet == .organizer {
                        PageOrganizerView(page: self.page).environment(\.managedObjectContext, self.viewContext)
                    } else if self.activeSheet == .feedEdit {
                        FeedEditView(feed: self.editingFeed!)
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
                            .actionSheet(isPresented: $showingActionSheet) {
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
        self.showingActionSheet = true
    }
    
    func showOrganizer() {
        self.activeSheet = .organizer
        self.showingSheet = true
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
