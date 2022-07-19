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
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var crashManager: CrashManager
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
                GeometryReader { geometry in
                    ScrollView(.vertical) {
                        itemDetail(frameSize: geometry.size)
                    }
                }
                .toolbar { toolbar }
            }
        }
        .background(Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all))
        .onChange(of: viewModel.item.feedData?.feed?.page) { _ in
            dismiss()
        }
    }

    @ViewBuilder
    private func itemDetail(frameSize: CGSize) -> some View {
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
                            heroImage(frameSize: frameSize)
                        }

                        Text(viewModel.item.summary!).lineSpacing(2)
                    }
                }
                .dynamicTypeSize(.large)
                .padding(12)
            }
            .frame(maxWidth: maxContentWidth)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 20)

        }.frame(maxWidth: .infinity)

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

    private func heroImage(frameSize: CGSize) -> some View {
        WebImage(url: viewModel.item.image)
            .resizable()
            .placeholder {
                imagePlaceholder
            }
            .aspectRatio(viewModel.item.imageAspectRatio, contentMode: .fit)
            .background(Color(UIColor.tertiarySystemGroupedBackground))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
            )
            .accessibility(label: Text("Hero Image"))

    }

    private var imagePlaceholder: some View {
        HStack {
            Image(systemName: "photo").imageScale(.large)
            Text(viewModel.item.image?.absoluteString ?? "Unknown address").lineLimit(1).frame(maxWidth: 156)
            Spacer()
            Button {
                UIPasteboard.general.string = viewModel.item.image?.absoluteString
            } label: {
                Label("Copy Image URL", systemImage: "doc.on.doc")
                    .imageScale(.small)
                    .labelStyle(.iconOnly)
            }
            .accessibilityIdentifier("image-copy-url-button")
        }
        .foregroundColor(.secondary)
        .padding()
    }
}
