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
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var feed: Feed
    
    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var body: some View {
        Group {
            if feed.managedObjectContext == nil {
                StatusBoxView(message: Text("Feed Deleted"), symbol: "slash.circle")
            } else {
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        if feed.hasContent {
                            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                                Section(header: header.modifier(PinnedSectionHeaderModifier())) {
                                    if hideRead == true && feed.feedData!.itemsArray.unread().isEmpty {
                                        AllReadCompactView()
                                            .background(Color(UIColor.secondarySystemGroupedBackground))
                                            .cornerRadius(8)
                                            .padding()
                                    } else {
                                        BoardView(
                                            width: geometry.size.width,
                                            list: visibleItems
                                        ) { item in
                                            ItemActionView(item: item) {
                                                ItemPreviewView(item: item)
                                            }
                                            .background(Color(UIColor.secondarySystemGroupedBackground))
                                            .cornerRadius(8)
                                        }
                                        .padding()
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
                            .frame(height: geometry.size.height)
                        }
                    }
                }
                .toolbar {
                    ToolbarItem {
                        NavigationLink(value: FeedPanel.feedSettings(feed)) {
                            Label("Feed Settings", systemImage: "wrench")
                        }
                        .buttonStyle(ToolbarButtonStyle())
                        .accessibilityIdentifier("feed-settings-button")
                        .disabled(refreshing)
                    }
                    
                    ToolbarItemGroup(placement: .bottomBar) {
                        FeedBottomBarView(
                            feed: feed,
                            hideRead: $hideRead,
                            refreshing: $refreshing,
                            unreadCount: feed.feedData?.itemsArray.unread().count ?? 0
                        )
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .onChange(of: feed.page) { _ in
            dismiss()
        }
        .navigationTitle(feed.wrappedTitle)
        .navigationDestination(for: FeedPanel.self, destination: { feedPanel in
            switch feedPanel {
            case .feedSettings(let feed):
                FeedSettingsView(feed: feed)
            }
        })
    }

    private var visibleItems: [Item] {
        guard let feedData = feed.feedData else { return [] }

        return feedData.previewItems.filter { item in
            hideRead ? item.read == false : true
        }
    }

    private var header: some View {
        HStack {
            if let linkDisplayString = feed.feedData?.linkDisplayString {
                Button {
                    SafariUtility.openLink(url: feed.feedData?.link)
                } label: {
                    HStack {
                        Label {
                            Text(linkDisplayString)
                        } icon: {
                            FeedFaviconView(url: feed.feedData?.favicon, placeholderSymbol: "globe")
                        }
                        Spacer()
                        Image(systemName: "link")
                            .foregroundColor(Color(UIColor.tertiaryLabel))
                            .imageScale(.small)
                            .font(.body.weight(.semibold))

                    }
                    .padding(.horizontal, 20)
                }
                .buttonStyle(
                    FeedTitleButtonStyle(backgroundColor: Color(UIColor.tertiarySystemGroupedBackground))
                )
            } else {
                Label {
                    Text("Website unknown").font(.caption)
                } icon: {
                    Image(systemName: "questionmark.square")
                }
                .foregroundColor(.secondary)
                .padding(.leading, 20)
                .padding(.trailing, 8)
            }
        }
        .lineLimit(1)
    }
}
