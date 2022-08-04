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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var linkManager: LinkManager

    @ObservedObject var item: Item

    @State private var webViewHeight: CGFloat = .zero

    let maxContentWidth: CGFloat = 720

    var body: some View {
        Group {
            if item.managedObjectContext == nil {
                StatusBoxView(message: Text("Item Deleted"), symbol: "slash.circle")
                    .navigationTitle("")
            } else {
                ScrollView(.vertical) {
                    VStack {
                        VStack(alignment: .leading, spacing: 0) {
                            FeedTitleLabelView(
                                title: item.feedTitle,
                                favicon: item.feedData?.favicon
                            )
                            .font(.title3)
                            .padding(.top, 12)
                            .padding(.horizontal, 12)

                            VStack(alignment: .leading, spacing: 16) {
                                Text(item.wrappedTitle).font(.largeTitle)

                                Text("\(item.date.fullLongDisplay())")
                                    .font(.subheadline)
                                    .lineLimit(1)

                                if item.body != nil {
                                    WebView(
                                        dynamicHeight: $webViewHeight,
                                        html: item.body!,
                                        title: item.wrappedTitle,
                                        baseURL: item.link
                                    )
                                } else if item.summary != nil {
                                    if item.image != nil {
                                        heroImage
                                    }
                                    Text(item.summary!).lineSpacing(2)
                                }
                            }
                            .dynamicTypeSize(.large)
                            .padding([.top, .horizontal], 12)
                            .padding(.bottom, 36)
                        }
                        .frame(maxWidth: maxContentWidth)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 36)

                    }.frame(maxWidth: .infinity)
                }
                .toolbar { toolbar }
            }
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        .onChange(of: item.feedData?.feed?.page) { _ in
            dismiss()
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            Button {
                linkManager.openLink(
                    url: item.link,
                    readerMode: item.feedData?.feed?.readerMode ?? false
                )
            } label: {
                Label("Open in Browser", systemImage: "safari")
            }
            .accessibilityIdentifier("item-open-button")
        }
    }

    private var heroImage: some View {
        WebImage(url: item.image)
            .resizable()
            .placeholder {
                ItemImagePlaceholderView(
                    imageURL: item.image,
                    aspectRatio: item.imageAspectRatio
                )
            }
            .aspectRatio(nil, contentMode: .fit)
            .frame(
                maxWidth: item.imageWidth > 0 ? CGFloat(item.imageWidth) : nil,
                maxHeight: item.imageHeight > 0 ? CGFloat(item.imageHeight) : nil,
                alignment: .top
            )
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
            )
            .accessibility(label: Text("Hero Image"))
    }
}
