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
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @ObservedObject var page: Page
    @State var showingSheet: Bool = false
    @State var activeSheet: PageSheet = .organizer
    @State var editingFeed: Feed?
    @State var showingActionSheet: Bool = false
    
    var body: some View {
        VStack {
            if page.name == nil {
                VStack() {
                    Text("Page Deleted").font(.title).foregroundColor(.secondary)
                }.navigationBarTitle("").navigationBarItems(trailing: EmptyView())
            } else {
                VStack(spacing: 0) {
                    GeometryReader { geometry in
                        if self.page.feedsArray.count > 0 {
                            VStack(spacing: 0) {
                                if self.refreshManager.isRefreshing(self.page) {
                                    HeaderProgressBarView(refreshable: self.page).frame(height: 2)
                                }
                                Divider()
                                
                                RefreshableScrollView(refreshable: self.page) {
                                    Grid(self.page.feedsArray) { feed in
                                        FeedView(feed: feed, parent: self)
                                    }
                                    .gridStyle(StaggeredGridStyle(.vertical, tracks: self.calcGridTracks(geometry.size.width), spacing: 16))
                                    .padding()
                                    .padding(.bottom, 64)
                                }
                            }
                            
                        } else {
                            Divider()
                            VStack(alignment: .center) {
                                Text("Empty Page").font(.title).foregroundColor(.secondary)
                            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(UIColor.secondarySystemBackground))
                        }
                    }
                    .background(Color(UIColor.secondarySystemBackground))
                    .sheet(isPresented: self.$showingSheet) {
                        if self.activeSheet == .organizer {
                            PageOrganizerView(page: self.page).environment(\.managedObjectContext, self.viewContext)
                        } else if self.activeSheet == .feedEdit {
                            FeedEditView(feed: self.editingFeed!).environment(\.managedObjectContext, self.viewContext)
                        }
                    }
                }
                .onAppear {
                    self.subscriptionManager.currentPage = self.page
                }
                .padding(.top, 1) // ScrollView will flow over the navigation bar background without padding. Maybe a SwiftUI bug?
                .navigationBarTitle(Text(page.name ?? "Unknown Page"), displayMode: .inline)
                .navigationBarItems(
                    trailing: HStack(alignment: .center, spacing: 16) {
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            // Action menu for phone users
                            Button(action: showMenu) {
                                Image(systemName: "wrench")
                            }
                            .actionSheet(isPresented: $showingActionSheet) {
                                ActionSheet(
                                    title: Text("Page Actions"),
                                    message: nil,
                                    buttons: [
                                        .default(Text("Refresh")) { self.refreshManager.refresh(self.page) },
                                        .default(Text("Organize")) { self.showOrganizer() },
                                        .default(Text("Add Feed")) { self.showSubscribe() },
                                        .cancel()
                                    ]
                                )
                            }
                        } else {
                            // Just show three buttons on larger screens
                            Button(action: { self.refreshManager.refresh(self.page) }) {
                                Image(systemName: "arrow.clockwise")
                            }.disabled(refreshManager.refreshing)
                            
                            Button(action: showOrganizer) {
                                Image(systemName: "arrow.up.arrow.down")
                            }
                            
                            Button(action: showSubscribe) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                )
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
        .edgesIgnoringSafeArea(.horizontal)
    }
    
    func showMenu() {
        self.showingActionSheet = true
    }
    
    func showOrganizer() {
        self.activeSheet = .organizer
        self.showingSheet = true
    }
    
    func showSubscribe() {
        self.subscriptionManager.subscribe()
    }
    
    private func calcGridTracks(_ availableWidth: CGFloat) -> Tracks {
        let widgetSize = CGFloat(480)
        for i in 1...10 {
            if availableWidth < widgetSize * CGFloat(i) {
                return Tracks.count(i)
            }
        }
        return Tracks.fixed(widgetSize)
    }
}
