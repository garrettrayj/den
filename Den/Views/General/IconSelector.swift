//
//  IconSelector.swift
//  Den
//
//  Created by Garrett Johnson on 8/14/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct IconSelector: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var symbol: String

    var body: some View {
        NavigationStack {
            List {
                ForEach(PageIconCategory.allCases, id: \.self) { category in
                    categorySection(category: category)
                }
            }
            .navigationTitle(Text("Choose Icon", comment: "Navigation title."))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Close", comment: "Button label.")
                    }
                }
            }
        }
        .frame(minWidth: 600, minHeight: 480)
    }

    let gridItem = GridItem(.adaptive(minimum: 40), spacing: 4, alignment: .center)

    private func categorySection(category: PageIconCategory) -> some View {
        Section {
            LazyVGrid(
                columns: [gridItem],
                alignment: .center,
                spacing: 4
            ) {
                ForEach(SymbolLibrary.shared.categorySymbols(categoryID: category.rawValue)) { categorySymbol in
                    ZStack {
                        RoundedRectangle(cornerRadius: 4).fill(.background)
                        if categorySymbol.id == symbol {
                            Image(systemName: categorySymbol.id).foregroundStyle(.tint)
                            RoundedRectangle(cornerRadius: 4).strokeBorder(.tint, lineWidth: 2)
                        } else {
                            Image(systemName: categorySymbol.id)
                        }
                    }
                    .imageScale(.large)
                    .aspectRatio(1, contentMode: .fit)
                    .onTapGesture {
                        symbol = categorySymbol.id
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
