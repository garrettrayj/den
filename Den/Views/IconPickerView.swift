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

    struct Category: Identifiable {
        var id: String
        var symbol: String
        var title: String
    }

    let categories: [Category] = [
        Category(id: "uncategorized", symbol: "square.grid.2x2", title: "Uncategorized"),
        Category(id: "communication", symbol: "bubble.left", title: "Communication"),
        Category(id: "weather", symbol: "cloud.sun", title: "Weather"),
        Category(id: "objectsandtools", symbol: "folder", title: "Objects and Tools"),
        Category(id: "devices", symbol: "desktopcomputer", title: "Devices"),
        Category(id: "gaming", symbol: "gamecontroller", title: "Gaming"),
        Category(id: "connectivity", symbol: "antenna.radiowaves.left.and.right", title: "Connectivity"),
        Category(id: "transportation", symbol: "car", title: "Transporation"),
        Category(id: "human", symbol: "person.crop.circle", title: "Human"),
        Category(id: "nature", symbol: "leaf", title: "Nature"),
        Category(id: "editing", symbol: "slider.horizontal.3", title: "Editing"),
        Category(id: "media", symbol: "playpause", title: "Media"),
        Category(id: "keyboard", symbol: "keyboard", title: "Keyboard"),
        Category(id: "commerce", symbol: "cart", title: "Commerce"),
        Category(id: "time", symbol: "timer", title: "Time"),
        Category(id: "health", symbol: "heart", title: "Health"),
        Category(id: "shapes", symbol: "square.on.circle", title: "Shapes"),
        Category(id: "arrows", symbol: "arrow.right", title: "Arrows"),
        Category(id: "math", symbol: "x.squareroot", title: "Math")
    ]

    struct Symbol: Identifiable {
        var id: String
        var categories: [String]
    }

    var symbols: [Symbol] =  []

    let columns = [
        GridItem(.adaptive(minimum: 36, maximum: 36), spacing: 4, alignment: .top)
    ]

    init(selectedSymbol: Binding<String>) {
        _selectedSymbol = selectedSymbol

        guard
            let symbolsPath = Bundle.main.path(forResource: "PageSymbols", ofType: "plist"),
            let symbolsPlist = NSDictionary(contentsOfFile: symbolsPath)
        else {
            preconditionFailure("Missing categories configuration")
        }

        if let symbolsDictionary = symbolsPlist as? [String: [String]] {
            for item in symbolsDictionary {
                self.symbols.append(Symbol(id: item.key, categories: item.value))
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16, pinnedViews: .sectionHeaders) {
                    ForEach(categories) { category in
                        categorySection(category: category)
                    }
                }.padding(.bottom)
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
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    private func categorySection(category: Category) -> some View {
        Section(
            header: Label(category.title, systemImage: category.symbol)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 28)
                .padding(.horizontal)
                .background(Color(UIColor.tertiarySystemGroupedBackground))
        ) {
            LazyVGrid(columns: columns, alignment: .center, spacing: 4) {
                ForEach(categorySymbols(categoryID: category.id)) { symbol in
                    Button {
                        selectedSymbol = symbol.id
                        dismiss()
                    } label: {
                        Image(systemName: symbol.id)
                            .imageScale(.large)
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

    private func categorySymbols(categoryID: String) -> [Symbol] {
        return symbols.filter { symbol in
            symbol.categories.contains(categoryID)
        }
    }
}
