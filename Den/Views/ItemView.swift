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

    @ObservedObject var viewModel: ItemViewModel

    @State private var webViewHeight: CGFloat = .zero

    let maxContentWidth: CGFloat = 720

    var body: some View {
        Group {
            if viewModel.item.managedObjectContext == nil {
                StatusBoxView(message: Text("Item Deleted"), symbol: "slash.circle")
                    .navigationTitle("")
            } else {
                ScrollView(.vertical) {
                    VStack {
                        VStack(alignment: .leading, spacing: 0) {
                            FeedTitleLabelView(
                                title: viewModel.item.feedTitle,
                                favicon: viewModel.item.feedData?.favicon
                            )
                            .font(.title3)
                            .padding(.top, 12)
                            .padding(.horizontal, 12)

                            VStack(alignment: .leading, spacing: 16) {
                                Text(viewModel.item.wrappedTitle).font(.largeTitle)

                                Text("\(viewModel.item.date.fullLongDisplay())")
                                    .font(.subheadline)
                                    .lineLimit(1)

                                if viewModel.item.body != nil {
                                    WebView(
                                        dynamicHeight: $webViewHeight,
                                        html: viewModel.item.body!,
                                        title: viewModel.item.wrappedTitle,
                                        baseURL: viewModel.item.link
                                    )
                                } else if viewModel.item.summary != nil {
                                    if viewModel.item.image != nil {
                                        heroImage
                                    }
                                    Text(viewModel.item.summary!).lineSpacing(2)
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
        .onChange(of: viewModel.item.feedData?.feed?.page) { _ in
            dismiss()
        }
    }

    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            Spacer()
            Button {
                linkManager.openLink(
                    url: viewModel.item.link,
                    readerMode: viewModel.item.feedData?.feed?.readerMode ?? false
                )
            } label: {
                Label("Open in Browser", systemImage: "safari")
            }
            .accessibilityIdentifier("item-open-button")
        }
    }

    private var heroImage: some View {
        WebImage(url: viewModel.item.image)
            .resizable()
            .placeholder {
                ItemImagePlaceholderView(
                    imageURL: viewModel.item.image,
                    aspectRatio: viewModel.item.imageAspectRatio
                )
            }
            .aspectRatio(nil, contentMode: .fit)
            .frame(
                maxWidth: viewModel.item.imageWidth > 0 ? CGFloat(viewModel.item.imageWidth) : nil,
                maxHeight: viewModel.item.imageHeight > 0 ? CGFloat(viewModel.item.imageHeight) : nil,
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
