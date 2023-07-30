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
    @Binding var symbolID: String

    var body: some View {
        List {
            ForEach(PageIconCategory.allCases, id: \.self) { category in
                categorySection(category: category)
            }
        }
    }

    #if os(macOS)
    let gridItem = GridItem(.adaptive(minimum: 32), spacing: 4, alignment: .center)
    #else
    let gridItem = GridItem(.adaptive(minimum: 40), spacing: 4, alignment: .center)
    #endif

    private func categorySection(category: PageIconCategory) -> some View {
        Section {
            LazyVGrid(
                columns: [gridItem],
                alignment: .center,
                spacing: 4
            ) {
                ForEach(SymbolLibrary.shared.categorySymbols(categoryID: category.rawValue)) { symbol in
                    ZStack {
                        RoundedRectangle(cornerRadius: 4).fill(.background)

                        if symbol.id == symbolID {
                            Image(systemName: symbol.id).foregroundStyle(.tint)
                            RoundedRectangle(cornerRadius: 4).strokeBorder(.tint, lineWidth: 2)
                        } else {
                            Image(systemName: symbol.id)
                        }
                    }
                    .imageScale(.large)
                    .aspectRatio(1, contentMode: .fit)
                    .onTapGesture {
                        symbolID = symbol.id
                    }
                    .accessibilityIdentifier("PageIconOption")
                }
            }
        } header: {
            Label {
                category.labelText
            } icon: {
                Image(systemName: category.labelIcon)
            }
        }
    }
}
