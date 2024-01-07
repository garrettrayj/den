//
//  IconSelector.swift
//  Den
//
//  Created by Garrett Johnson on 8/14/21.
//  Copyright © 2021 Garrett Johnson
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
            .navigationTitle(Text("Select Icon", comment: "Navigation title."))
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
        .frame(minWidth: 360, minHeight: 480)
    }

    #if os(macOS)
    let gridItem = GridItem(.adaptive(minimum: 36), spacing: 4, alignment: .center)
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
