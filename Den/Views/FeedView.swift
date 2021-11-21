//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 11/10/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

import Grid

struct FeedView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var refreshManager: RefreshManager

    @ObservedObject var feed: Feed

    @Binding var refreshing: Bool
    @State var showingSettings: Bool = false

    var body: some View {
        Group {
            #if targetEnvironment(macCatalyst)
            ScrollView {
                feedContent
            }
            #else
            RefreshableScrollView(
                refreshing: $refreshing,
                onRefresh: { _ in
                    refreshManager.refresh(feed: feed)
                },
                content: { feedContent }
            )
            #endif
        }
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .background(
            Group {
                NavigationLink(
                    destination: FeedSettingsView(feed: feed),
                    isActive: $showingSettings
                ) {
                    EmptyView()
                }

                // Hidden button for iOS keyboard shortcuts
                #if !targetEnvironment(macCatalyst)
                Button {
                    refreshManager.refresh(feed: feed)
                } label: {
                    EmptyView()
                }
                .keyboardShortcut("r", modifiers: [.command])
                .hidden()
                #endif
            }
        )
        .navigationTitle(feed.wrappedTitle)
        .toolbar {
            ToolbarItem {
                Button {
                    showingSettings = true
                } label: {
                    Label("Feed Settings", systemImage: "wrench")
                }
                .buttonStyle(NavigationBarButtonStyle())
                .disabled(refreshing)
            }

            #if targetEnvironment(macCatalyst)
            ToolbarItem {
                Button {
                    refreshManager.refresh(feed: feed)
                } label: {
                    if refreshing {
                        ProgressView().progressViewStyle(NavigationBarProgressStyle())
                    } else {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }
                .buttonStyle(NavigationBarButtonStyle())
                .keyboardShortcut("r", modifiers: [.command])
                .disabled(refreshing)
            }
            #endif
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .feedWillBeDeleted, object: feed.objectID)
        ) { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        }
    }

    private var feedHeader: some View {
        HStack {
            if feed.feedData?.linkDisplayString != nil {
                if feed.feedData?.faviconImage != nil {
                    feed.feedData!.faviconImage!
                        .scaleEffect(1 / UIScreen.main.scale)
                        .frame(width: 16, height: 16, alignment: .center)
                        .clipped()
                }

                Text(feed.feedData?.linkDisplayString ?? "").font(.callout)
            }

            Spacer()

            lastRefreshedLabel()
                .foregroundColor(.secondary)
                .font(.footnote)
        }
        .lineLimit(1)
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground))
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var feedContent: some View {
        VStack {
            if feed.feedData != nil && feed.feedData!.itemsArray.count > 0 {
                feedHeader

                Grid(feed.feedData!.itemsArray, id: \.self) { item in
                    FeedItemView(item: item)
                }
                .gridStyle(StaggeredGridStyle(.vertical, tracks: Tracks.min(300), spacing: 16))
                .padding(.top, 8)
                .padding(.horizontal, 16)
                .padding(.bottom, 64)
            } else {
                if feed.feedData == nil {
                    Text("Refresh to fetch content").modifier(SimpleMessageModifier())
                } else if feed.feedData?.error != nil {
                    Text("Unable to update feed").modifier(SimpleMessageModifier())
                } else if feed.feedData!.itemsArray.count == 0 {
                    Text("Feed empty").modifier(SimpleMessageModifier())
                } else {
                    Text("Feed status unavailable").modifier(SimpleMessageModifier())
                }
            }
        }
    }

    private func lastRefreshedLabel() -> Text {
        guard let lastRefreshed = feed.feedData?.refreshed else {
            return Text("First refresh")
        }

        return Text("\(lastRefreshed, formatter: DateFormatter.mediumShort)")
    }
}
