//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct FeedView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var feed: Feed
    @State var unreadCount: Int
    @Binding var refreshing: Bool
    @AppStorage("hideRead") var hideRead = false

    var body: some View {
        Group {
            if feed.managedObjectContext == nil {
                StatusBoxView(message: Text("Feed Deleted"), symbol: "slash.circle")
                    .navigationTitle("")
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        feedItems(frameSize: geometry.size)
                    }
                }
                .toolbar { toolbar }
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onChange(of: feed.page) { _ in
            dismiss()
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .itemStatus, object: nil)
        ) { notification in
            guard
                let feedObjectID = notification.userInfo?["feedObjectID"] as? NSManagedObjectID,
                feedObjectID == feed.objectID,
                let read = notification.userInfo?["read"] as? Bool
            else {
                return
            }
            unreadCount += read ? -1 : 1
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .feedRefreshed, object: feed.objectID)
        ) { _ in
            unreadCount = feed.feedData?.previewItems.count ?? 0
        }
        .navigationTitle(feed.wrappedTitle)
    }

    private var visibleItems: [Item] {
        guard let feedData = feed.feedData else { return [] }

        return feedData.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }

    @ViewBuilder
    private func feedItems(frameSize: CGSize) -> some View {
        if feed.hasContent {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                Section(header: header.modifier(PinnedSectionHeaderModifier())) {
                    if hideRead == true && feed.feedData!.itemsArray.unread().isEmpty {
                        AllReadCompactView(numHidden: feed.feedData!.previewItems.read().count)
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                            .padding()
                    } else {
                        BoardView(
                            width: frameSize.width,
                            list: visibleItems
                        ) { item in
                            ItemActionView(item: item) {
                                ItemPreviewView(item: item)
                            }
                            .background(Color(UIColor.secondarySystemGroupedBackground))
                            .cornerRadius(8)
                        }.padding()
                    }
                }
            }
        } else {
            VStack {
                Spacer()
                FeedUnavailableView(feedData: feed.feedData, useStatusBox: true)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: frameSize.height)
        }
    }

    private var header: some View {
        HStack {
            if feed.feedData?.linkDisplayString != nil {
                Button {
                    SyncManager.openLink(context: viewContext, url: feed.feedData?.link)
                } label: {
                    HStack {
                        Label {
                            Text(feed.feedData!.linkDisplayString!)
                        } icon: {
                            FeedFaviconView(url: feed.feedData?.favicon, placeholderSymbol: "globe")
                        }
                        Spacer()
                        Image(systemName: "link")
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .imageScale(.small)
                            .font(.body.weight(.semibold))

                    }
                    .padding(.horizontal, 28)
                }
                .buttonStyle(
                    FeedTitleButtonStyle(backgroundColor: Color(UIColor.tertiarySystemGroupedBackground))
                )
            } else {
                Label {
                    Text("Website Unknown").font(.caption)
                } icon: {
                    Image(systemName: "questionmark.square")
                }
                .foregroundColor(.secondary)
                .padding(.leading, 28)
                .padding(.trailing, 8)
            }
        }
        .lineLimit(1)
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            if refreshing {
                ProgressView()
                    .progressViewStyle(ToolbarProgressStyle())
            } else {
                NavigationLink(value: DetailPanel.feedSettings(feed)) {
                    Label("Feed Settings", systemImage: "wrench")
                }
                .modifier(ToolbarButtonModifier())
                .disabled(refreshing)
                .accessibilityIdentifier("feed-settings-button")
            }
        }

        ReadingToolbarContent(
            unreadCount: $unreadCount,
            hideRead: $hideRead,
            refreshing: $refreshing,
            centerLabel: Text("\(feed.feedData?.itemsArray.unread().count ?? 0) Unread")
        ) {
            withAnimation {
                SyncManager.toggleReadUnread(context: viewContext, items: feed.feedData?.previewItems ?? [])
                feed.objectWillChange.send()
            }
        }
    }
}
