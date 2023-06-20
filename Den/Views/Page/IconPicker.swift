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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var symbolID: String

    var columnWidth: CGFloat {
        return 36 * dynamicTypeSize.layoutScalingFactor
    }

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: columnWidth), spacing: 4, alignment: .center)
                ],
                alignment: .center,
                spacing: 4,
                pinnedViews: .sectionHeaders
            ) {
                ForEach(SymbolCollection.shared.categories) { category in
                    categorySection(category: category)
                }
            }
        }
        .background(GroupedBackground())
    }

    private func categorySection(category: SymbolCollection.Category) -> some View {
        Section {
            ForEach(SymbolCollection.shared.categorySymbols(categoryID: category.id)) { symbol in
                ZStack {
                    RoundedRectangle(cornerRadius: 4).fill(.background)
                    Image(systemName: symbol.id)
                        .imageScale(.large)
                        .foregroundColor(symbol.id == symbolID ? .accentColor : .primary)

                    if symbol.id == symbolID {
                        RoundedRectangle(cornerRadius: 4).strokeBorder(Color.accentColor, lineWidth: 2)
                    }
                }
                .aspectRatio(1, contentMode: .fit)
                .onTapGesture {
                    symbolID = symbol.id
                }
                .accessibilityIdentifier("select-icon-button")
            }
        } header: {
            Label(category.title, systemImage: category.symbol)
                .modifier(PinnedSectionHeaderModifier())
        }
    }
}
