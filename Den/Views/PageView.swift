//
//  PageView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import Grid

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

enum PageSheet {
    case organizer, feedEdit, subscribe
}

/**
 Grid layout of Feed views. Hosts sheets for editing and organizing feeds, subscribing to new feeds.
 */
struct PageView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var page: Page
    @ObservedObject var updateManager: UpdateManager
    @State var showingSheet: Bool = false
    @State var activeSheet: PageSheet = .organizer
    @State var editingFeed: Feed?
    @State var showingMenu: Bool = false
    
    var body: some View {
        Group {
            if page.name == nil {
                VStack() {
                    Text("Page Deleted").font(.title).foregroundColor(.secondary)
                }.navigationBarTitle("").navigationBarItems(trailing: EmptyView())
            } else {
                VStack(spacing: 0) {
                    GeometryReader { geometry in
                        if self.page.feedsArray.count > 0 {
                            VStack(spacing: 0) {
                                if self.updateManager.updating {
                                    HeaderProgressBarView(updateManager: self.updateManager).frame(height: 2)
                                }
                                Divider()
                                
                                RefreshableScrollView(updateManager: self.updateManager) {
                                    Grid(self.page.feedsArray) { feed in
                                        FeedView(feed: feed, parent: self)
                                    }
                                    .gridStyle(StaggeredGridStyle(.vertical, tracks: self.calcGridTracks(geometry.size.width), spacing: 16))
                                    .padding()
                                    .padding(.bottom, 64)
                                }.background(Color(UIColor.secondarySystemBackground))
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
                        } else if self.activeSheet == .subscribe {
                            SubscribeView(page: self.page).environment(\.managedObjectContext, self.viewContext)
                        }
                    }
                }
                .padding(.top, 1) // ScrollView will flow over the navigation bar background without padding. Maybe a SwiftUI bug?
                .navigationBarTitle(Text(page.name ?? "Unknown Page"), displayMode: .inline)
                .navigationBarItems(
                    trailing: HStack(alignment: .center, spacing: 16) {
                        if UIDevice.current.userInterfaceIdiom == .phone {
                            // Action menu for phone users
                            Button(action: showMenu) {
                                Image(systemName: "ellipsis")
                            }.actionSheet(isPresented: $showingMenu) {
                                ActionSheet(
                                    title: Text("Page Actions"),
                                    message: nil,
                                    buttons: [
                                        .default(Text("Refresh")) { self.updateManager.update() },
                                        .default(Text("Organize")) { self.showOrganizer() },
                                        .default(Text("Add Feed")) { self.showSubscribe() },
                                        .cancel()
                                    ]
                                )
                            }
                        } else {
                            // Just show three buttons on larger screens
                            Button(action: updateManager.update) {
                                Image(systemName: "arrow.clockwise").modifier(TitleBarButtonAreaModifier())
                            }
                            
                            Button(action: showOrganizer) {
                                Image(systemName: "arrow.up.arrow.down").modifier(TitleBarButtonAreaModifier())
                            }
                            
                            Button(action: showSubscribe) {
                                Image(systemName: "plus").modifier(TitleBarButtonAreaModifier())
                            }
                        }
                    }
                )
            }
        }
    }
    
    func showMenu() {
        self.showingMenu = true
    }
    
    func showOrganizer() {
        self.activeSheet = .organizer
        self.showingSheet = true
    }
    
    func showSubscribe() {
        self.activeSheet = .subscribe
        self.showingSheet = true
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
