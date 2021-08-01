//
//  FeedWidgetView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedWidgetView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentation
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var refreshManager: RefreshManager
    @ObservedObject var feed: Feed

    @State private var showingFeedPreferences: Bool = false

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground))
            widgetContent
        }
    }

    private var widgetContent: some View {
        VStack(spacing: 0) {
            feedHeader
            if feed.feedData != nil && feed.feedData!.itemsArray.count > 0 {
                feedItems
            } else {
                Divider()

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
        }
        .sheet(isPresented: $showingFeedPreferences) {
            FeedWidgetSettingsView(feed: feed)
                .environment(\.managedObjectContext, viewContext)
                .environment(\.colorScheme, colorScheme)
                .environmentObject(refreshManager)
                .environmentObject(crashManager)
        }
    }

    private var feedHeader: some View {
        HStack {
            HStack {
                if feed.feedData?.faviconImage != nil {
                    feed.feedData!.faviconImage!
                        .scaleEffect(1 / UIScreen.main.scale)
                        .frame(width: 16, height: 16, alignment: .center)
                        .clipped()
                }
                Text(feed.wrappedTitle).font(.headline).lineLimit(1)
            }

            Spacer()

            Button(action: showOptions) {
                Label("Feed Settings", systemImage: "gearshape").labelStyle(IconOnlyLabelStyle())
            }.disabled(refreshManager.refreshing).padding(12)
        }.padding(.leading, 12)
    }

    private var feedItems: some View {
        VStack(spacing: 0) {
            ForEach(feed.feedData!.itemsArray.prefix(feed.page?.wrappedItemsPerFeed ?? 5)) { item in
                Group {
                    Divider()
                    FeedWidgetItemRowView(item: item, feed: feed)
                }
            }
        }
    }

    private var feedError: some View {
        VStack {
            VStack(spacing: 4) {
                Text("Unable to Update Feed")
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
        Text("Feed Empty")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }

    private var feedNotFetched: some View {
        Text("Refresh to Fetch Content")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }

    private var feedStatusUnknown: some View {
        Text("Feed Status Unavailable")
            .foregroundColor(.secondary)
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .multilineTextAlignment(.center)
    }

    private func showOptions() {
        self.showingFeedPreferences = true
    }
}
