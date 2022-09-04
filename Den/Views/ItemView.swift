//
//  ItemView.swift
//  Den
//
//  Created by Garrett Johnson on 7/8/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct ItemView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var item: Item

    @State private var webViewHeight: CGFloat = .zero

    let maxContentWidth: CGFloat = 720

    var body: some View {
        VStack {
            if item.managedObjectContext == nil {
                StatusBoxView(message: Text("Item Deleted"), symbol: "slash.circle")
                    .navigationTitle("")
            } else {
                ScrollView(.vertical) {
                    VStack {
                        VStack(alignment: .leading, spacing: 16) {
                            FeedTitleLabelView(
                                title: item.feedTitle,
                                favicon: item.feedData?.favicon
                            )
                            .font(.title3)

                            Text(item.wrappedTitle)
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.title)

                            Text("\(item.date.fullShortDisplay())").font(.subheadline).lineLimit(1)

                            if
                                item.image != nil &&
                                !(item.summary?.contains("<img") ?? false) &&
                                !(item.body?.contains("<img") ?? false)
                            {
                                heroImage
                            }

                            if item.body != nil || item.summary != nil {
                                WebView(
                                    dynamicHeight: $webViewHeight,
                                    html: item.body ?? item.summary!,
                                    title: item.wrappedTitle,
                                    baseURL: item.link
                                )
                            }

                        }
                        .padding(28)
                        .frame(maxWidth: maxContentWidth)
                    }.frame(maxWidth: .infinity)
                }
                .toolbar { toolbar }
            }
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                SyncManager.markItemRead(context: viewContext, item: item)
            }
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        if let link = item.link {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareLink(item: link).modifier(ToolbarButtonModifier())
            }
        }

        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            Button {
                SyncManager.openLink(context: viewContext, url: item.link)
            } label: {
                #if targetEnvironment(macCatalyst)
                Label("Open in Browser", systemImage: "link.circle")
                #else
                Label("Open in Browser", systemImage: "safari")
                #endif
            }
            .modifier(ToolbarButtonModifier())
            .accessibilityIdentifier("item-open-button")
        }
    }

    private var heroImage: some View {
        WebImage(url: item.image)
            .resizable()
            .aspectRatio(item.imageAspectRatio, contentMode: .fill)
            .frame(maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
            )
            .accessibility(label: Text("Hero Image"))
    }
}
