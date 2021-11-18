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
        VStack(spacing: 0) {
            if feed.feedData != nil && feed.feedData!.itemsArray.count > 0 {
                feedItems
            } else {
                if feed.feedData == nil {
                    feedNotFetched
                } else if feed.feedData?.error != nil {
                    feedError
                } else if feed.feedData!.itemsArray.count == 0 {
                    feedEmpty
                } else {
                    feedStatusUnknown
                }
            }
            Spacer()
        }
        .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
        .background(NavigationLink(
            destination: FeedSettingsView(feed: feed),
            isActive: $showingSettings
        ) {
            EmptyView()
        })
        .navigationTitle(feed.wrappedTitle)
        .toolbar {
            ToolbarItem {
                Button {
                    showingSettings = true
                } label: {
                    Label("Feed Settings", systemImage: "wrench")
                }
                .buttonStyle(ToolbarButtonStyle())
                .disabled(refreshing)
            }

            ToolbarItem {
                if refreshing {
                    ProgressView().progressViewStyle(ToolbarProgressStyle())
                } else {
                    Button {
                        refreshManager.refresh(feed: feed)
                    } label: {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .keyboardShortcut("r", modifiers: [.command])
                    .disabled(refreshing)
                }
            }
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
            if feed.feedData?.faviconImage != nil {
                feed.feedData!.faviconImage!
                    .scaleEffect(1 / UIScreen.main.scale)
                    .frame(width: 16, height: 16, alignment: .center)
                    .clipped()
            } else {
                Image(uiImage: UIImage(named: "RSSIcon")!)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.secondary)
                    .frame(width: 14, height: 14, alignment: .center)
            }

            Text(feed.feedData?.linkDisplayString ?? "Website not available")
                .font(.callout)

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

    private var feedItems: some View {
        ScrollView {
            feedHeader

            Grid(feed.feedData!.itemsArray, id: \.self) { item in
                FeedItemView(item: item)
            }
            .gridStyle(StaggeredGridStyle(.vertical, tracks: Tracks.min(300), spacing: 16))
            .padding(.top, 8)
            .padding(.horizontal, 16)
            .padding(.bottom, 64)
        }
    }

    private var feedError: some View {
        VStack {
            VStack(spacing: 4) {
                Text("Unable to update feed")
                    .foregroundColor(.secondary)
                    .font(.callout)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(feed.feedData!.error!)
                    .foregroundColor(.red)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(
            RoundedRectangle(cornerRadius: 4)
                .stroke(lineWidth: 1)
                .foregroundColor(.red)
        )
        .padding([.horizontal, .top])
        .padding(.bottom, 2)
    }

    private var feedEmpty: some View {
        Text("Feed empty")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }

    private var feedNotFetched: some View {
        Text("Refresh to fetch content")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }

    private var feedStatusUnknown: some View {
        Text("Feed status unavailable")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }

    private func lastRefreshedLabel() -> Text {
        guard let lastRefreshed = feed.feedData?.refreshed else {
            return Text("First refresh")
        }

        return Text("\(lastRefreshed, formatter: DateFormatter.longShort)")
    }
}
