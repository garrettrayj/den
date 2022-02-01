//
//  IconPickerView.swift
//  Den
//
//  Created by Garrett Johnson on 8/14/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct IconPickerView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var selectedSymbol: String

    let columns = [
        GridItem(.adaptive(minimum: 36, maximum: 36), spacing: 4, alignment: .top)
    ]

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16, pinnedViews: .sectionHeaders) {
                ForEach(SymbolCollection.shared.categories) { category in
                    categorySection(category: category)
                }
            }.padding(.bottom)
        }
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Select Icon")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func categorySection(category: SymbolCollection.Category) -> some View {
        Section(
            header: Label(category.title, systemImage: category.symbol)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 32)
                .padding(.horizontal, 28)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
        ) {
            LazyVGrid(columns: columns, alignment: .center, spacing: 4) {
                ForEach(SymbolCollection.shared.categorySymbols(categoryID: category.id)) { symbol in
                    Button {
                        selectedSymbol = symbol.id
                    } label: {
                        Image(systemName: symbol.id)
                            .foregroundColor(symbol.id == selectedSymbol ? .accentColor : .primary)
                            .frame(width: 36, height: 36, alignment: .center)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(
                                        Color.accentColor,
                                        lineWidth: symbol.id == selectedSymbol ? 2 : 0
                                    )
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
