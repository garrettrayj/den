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
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var crashManager: CrashManager
    @EnvironmentObject private var linkManager: LinkManager

    @ObservedObject var viewModel: FeedViewModel

    @State var showingSettings: Bool = false

    @AppStorage("feedHideRead_na") var hideRead = false

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel

        _hideRead = AppStorage(
            wrappedValue: false,
            "feedHideRead_\(viewModel.feed.id?.uuidString ?? "na")"
        )
    }

    var body: some View {
        Group {
            if viewModel.feed.managedObjectContext == nil {
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
                destination: FeedSettingsView(
                    viewModel: FeedSettingsViewModel(
                        viewContext: viewContext,
                        crashManager: crashManager,
                        feed: viewModel.feed
                    )
                ),
                isActive: $showingSettings
            ) {
                EmptyView()
            }
        )
        .onChange(of: viewModel.feed.page) { _ in
            dismiss()
        }
        .navigationTitle(viewModel.feed.wrappedTitle)
    }

    private var visibleItems: [Item] {
        guard let feedData = viewModel.feed.feedData else { return [] }

        return feedData.limitedItems.filter { item in
            hideRead ? item.read == false : true
        }
    }

    @ViewBuilder
    private func feedItems(frameSize: CGSize) -> some View {
        if viewModel.feed.hasContent {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                Section(header: header.modifier(PinnedSectionHeaderModifier())) {
                    if hideRead == true && viewModel.feed.feedData!.unreadItems.isEmpty {
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
                            ItemPreviewView(item: item)
                                .modifier(GroupBlockModifier())
                                .onTapGesture {
                                    openItem(item: item)
                                }
                        }.padding()
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom)
        } else {
            VStack {
                Spacer()
                FeedUnavailableView(feedData: viewModel.feed.feedData, useStatusBox: true)
                Spacer()
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: frameSize.height - 24)
            .padding()
        }
    }

    private var header: some View {
        HStack {
            if viewModel.feed.feedData?.linkDisplayString != nil {
                Button {
                    linkManager.openLink(url: viewModel.feed.feedData?.link)
                } label: {
                    HStack {
                        Label {
                            Text(viewModel.feed.feedData!.linkDisplayString!)
                        } icon: {
                            WebImage(url: viewModel.feed.feedData?.favicon)
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
            if viewModel.refreshing {
                ProgressView().progressViewStyle(ToolbarProgressStyle())
            } else {
                Button {
                    showingSettings = true
                } label: {
                    Label("Feed Settings", systemImage: "wrench")
                }
                .disabled(viewModel.refreshing)
                .accessibilityIdentifier("feed-settings-button")
            }
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
                Text("\(viewModel.feed.feedData?.unreadItems.count ?? 0) Unread").font(.caption)
            }
            Spacer()
            Button {
                // Toggle all read/unread
                if viewModel.feed.feedData?.unreadItems.isEmpty == true {
                    linkManager.markAllUnread(feed: viewModel.feed)
                    viewModel.feed.feedData?.itemsArray.forEach { item in
                        item.objectWillChange.send()
                    }
                    viewModel.objectWillChange.send()
                } else {
                    linkManager.markAllRead(feed: viewModel.feed)
                    viewModel.feed.feedData?.itemsArray.forEach { item in
                        item.objectWillChange.send()
                    }
                    viewModel.objectWillChange.send()
                }
            } label: {
                Label(
                    "Mark All Read",
                    systemImage: viewModel.feed.feedData?.unreadItems.isEmpty ?? false ?
                        "checkmark.circle.fill" : "checkmark.circle"
                )
            }
            .accessibilityIdentifier("mark-all-read-button")
            .disabled(viewModel.refreshing)
        }
    }

    private func openItem(item: Item) {
        linkManager.openLink(
            url: item.link,
            logHistoryItem: item,
            readerMode: item.feedData?.feed?.readerMode ?? false
        )
        item.objectWillChange.send()
    }
}
