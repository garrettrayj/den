//
//  IconPicker.swift
//  Den
//
//  Created by Garrett Johnson on 8/14/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct IconPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var page: Page

    var columnWidth: CGFloat {
        return 36 * dynamicTypeSize.layoutScalingFactor
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
            .background(GroupedBackground())
            .navigationTitle(Text("Choose Icon", comment: "Navigation title."))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Label {
                            Text("Close", comment: "Button label.")
                        } icon: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                    .buttonStyle(PlainToolbarButtonStyle())
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
                            .foregroundColor(symbol.id == page.wrappedSymbol ? .accentColor : .primary)

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
