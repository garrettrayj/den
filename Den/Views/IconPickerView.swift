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
    @ObservedObject var page: Page

    let columns = [
        GridItem(.adaptive(minimum: 40, maximum: 40), spacing: 4, alignment: .top)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: .sectionHeaders) {
                    ForEach(SymbolCollection.shared.categories) { category in
                        categorySection(category: category)
                    }
                }.padding(.bottom, 40)
            }
            .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
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
                        page.wrappedSymbol = symbol.id
                    } label: {
                        Image(systemName: symbol.id)
                            .imageScale(.large)
                            .foregroundColor(symbol.id == page.wrappedSymbol ? .accentColor : .primary)
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(
                                        Color.accentColor,
                                        lineWidth: symbol.id == page.wrappedSymbol ? 2 : 0
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("select-icon-button")
                }
            }
            .padding(.horizontal)
        }
    }
}
