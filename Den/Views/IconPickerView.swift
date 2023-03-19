//
//  IconPickerView.swift
//  Den
//
//  Created by Garrett Johnson on 8/14/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct IconPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.contentSizeCategory) private var contentSizeCategory

    @ObservedObject var page: Page

    var columnWidth: CGFloat {
        let typeSize = DynamicTypeSize(contentSizeCategory) ?? dynamicTypeSize
        return 36 * typeSize.fontScale
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, pinnedViews: .sectionHeaders) {
                    ForEach(SymbolCollection.shared.categories) { category in
                        categorySection(category: category)
                    }
                }.padding(.bottom)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Icon")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label("Close", systemImage: "xmark.circle")
                    }.buttonStyle(PlainToolbarButtonStyle())
                }
            }
        }
    }

    private func categorySection(category: SymbolCollection.Category) -> some View {
        Section {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: columnWidth), spacing: 4, alignment: .center)
                ],
                alignment: .center,
                spacing: 4
            ) {
                ForEach(SymbolCollection.shared.categorySymbols(categoryID: category.id)) { symbol in
                    ZStack {
                        RoundedRectangle(cornerRadius: 4).fill(.background)
                        
                        Image(systemName: symbol.id)
                            .imageScale(.large)
                            .foregroundColor(symbol.id == page.wrappedSymbol ? Color(.tintColor) : Color(.label))

                        if symbol.id == page.wrappedSymbol {
                            RoundedRectangle(cornerRadius: 4).strokeBorder(Color.accentColor, lineWidth: 2)
                        }
                    }
                    
                    .aspectRatio(1, contentMode: .fit)
                    .onTapGesture {
                        page.wrappedSymbol = symbol.id
                    }
                    .accessibilityIdentifier("select-icon-button")
                }
            }
            .padding(.horizontal)
        } header: {
            Label(category.title, systemImage: category.symbol)
                .modifier(PinnedSectionHeaderModifier())
        }

    }
}
