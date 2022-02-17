//
//  PageSettingsView.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageSettingsView: View {
    @ObservedObject var viewModel: PageSettingsViewModel

    var body: some View {
        Form {
            nameIconSection
            feedsSection
        }
        .navigationTitle("Page Settings")
        .environment(\.editMode, .constant(.active))
        .onDisappear(perform: viewModel.save)
        .background(
            NavigationLink(isActive: $viewModel.showingIconPicker, destination: {
                IconPickerView(selectedSymbol: $viewModel.page.wrappedSymbol)
            }, label: {
                EmptyView()
            })
        )
    }

    private var nameIconSection: some View {
        Section(header: Text("Name")) {
            HStack {
                TextField("Untitled", text: $viewModel.page.wrappedName)
                    .modifier(TitleTextFieldModifier())

                HStack {
                    Image(systemName: viewModel.page.wrappedSymbol)
                        .imageScale(.medium)
                        .foregroundColor(Color.accentColor)

                    Image(systemName: "chevron.down")
                        .imageScale(.small)
                        .foregroundColor(.secondary)

                }
                .onTapGesture { viewModel.showingIconPicker = true }
            }.modifier(FormRowModifier())
        }.modifier(SectionHeaderModifier())
    }

    private var feedsSection: some View {
        Section(header: Text("Feeds")) {
            if viewModel.page.feedsArray.isEmpty {
                Text("Page Empty").foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
            } else {
                ForEach(viewModel.page.feedsArray) { feed in
                    FeedTitleLabelView(
                        title: feed.wrappedTitle,
                        faviconImage: feed.feedData?.faviconImage
                    ).padding(.vertical, 4)
                }
                .onDelete(perform: viewModel.deleteFeed)
                .onMove(perform: viewModel.moveFeed)
            }
        }.modifier(SectionHeaderModifier())
    }

}
