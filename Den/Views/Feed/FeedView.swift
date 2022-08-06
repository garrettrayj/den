//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var syncManager: SyncManager

    @ObservedObject var feed: Feed

    @State var showingSettings: Bool = false

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
        .background(
            NavigationLink(
                destination: FeedSettingsView(feed: feed),
                isActive: $showingSettings
            ) {
                EmptyView()
            }
        )
        .onChange(of: feed.page) { _ in
            dismiss()
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
                        Label("No unread items", systemImage: "checkmark")
                            .imageScale(.small)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(12)
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
            .padding(.top, 8)
            .padding(.bottom)
        } else {
            VStack {
                Spacer()
                FeedUnavailableView(feedData: feed.feedData, useStatusBox: true)
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: frameSize.height - 36)
        }
    }

    private var header: some View {
        HStack {
            if feed.feedData?.linkDisplayString != nil {
                Button {
                    syncManager.openLink(url: feed.feedData?.link)
                } label: {
                    HStack {
                        Label {
                            Text(feed.feedData!.linkDisplayString!)
                        } icon: {
                            WebImage(url: feed.feedData?.favicon)
                                .resizable()
                                .placeholder {
                                    Image(systemName: "globe")
                                }
                                .frame(width: ImageSize.favicon.width, height: ImageSize.favicon.height)
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
            Button {
                showingSettings = true
            } label: {
                Label("Feed Settings", systemImage: "wrench")
            }
            .accessibilityIdentifier("feed-settings-button")
        }

        ToolbarItemGroup(placement: .bottomBar) {
            Button {
                withAnimation {
                    hideRead.toggle()
                }
            } label: {
                Label(
                    "Filter Read",
                    systemImage: hideRead ?
                        "line.3.horizontal.decrease.circle.fill"
                        : "line.3.horizontal.decrease.circle"
                )
            }
            Spacer()
            VStack {
                Text("\(feed.feedData?.itemsArray.unread().count ?? 0) Unread").font(.caption)
            }
            Spacer()
            Button {
                syncManager.toggleReadUnread(items: feed.feedData?.previewItems ?? [])
            } label: {
                Label(
                    "Mark All Read",
                    systemImage: feed.feedData?.itemsArray.unread().isEmpty ?? false ?
                        "checkmark.circle.fill" : "checkmark.circle"
                )
            }
            .accessibilityIdentifier("mark-all-read-button")
        }
    }
}
