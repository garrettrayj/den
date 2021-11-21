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

    var symbols: [String: [String]] =  [:]

    let categories: [[String]] = [
        ["miscellaneous", "square.grid.2x2"],
        ["communication", "bubble.left"],
        ["weather", "cloud.sun"],
        ["objectsandtools", "folder"],
        ["devices", "desktopcomputer"],
        ["connectivity", "antenna.radiowaves.left.and.right"],
        ["transportation", "car"],
        ["human", "person.crop.circle"],
        ["nature", "leaf"],
        ["editing", "slider.horizontal.3"],
        ["commerce", "cart"],
        ["time", "timer"],
        ["health", "heart"],
        ["shapes", "square.on.circle"],
        ["arrows", "arrow.right"],
        ["math", "x.squareroot"]
    ]

    let columns = [
        GridItem(.adaptive(minimum: 32, maximum: 32), spacing: 8, alignment: .top)
    ]

    var body: some View {
        NavigationView {
            Form {
                ForEach(categories, id: \.self) { category in
                    Section(header: Text(category[0]).modifier(SectionHeaderModifier())) {
                        symbolGrid(category: category[0]).listRowInsets(EdgeInsets())
                    }
                }
            }
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
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
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func symbolGrid(category: String) -> some View {
        LazyVGrid(columns: columns) {
            ForEach(symbols.keys.sorted(), id: \.self) { key in
                if symbols[key]!.contains(category) {

                    Image(systemName: key)
                        .imageScale(.medium)
                        .foregroundColor(key == selectedSymbol ? .accentColor : .primary)
                        .frame(width: 32, height: 32, alignment: .center)
                        .background(
                            RoundedRectangle(cornerRadius: 4).fill(Color(UIColor.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(
                                    Color.accentColor,
                                    lineWidth: key == selectedSymbol ? 2 : 0
                                )
                        )
                        .onTapGesture {
                            selectedSymbol = key
                        }

                }
            }
        }
        .padding(.vertical)
    }

    init(selectedSymbol: Binding<String>) {
        _selectedSymbol = selectedSymbol

        guard
            let symbolsPath = Bundle.main.path(forResource: "page_symbols", ofType: "plist"),
            let symbolsDict = NSDictionary(contentsOfFile: symbolsPath)
        else {
            preconditionFailure("Missing categories configuration")
        }

        if let symbols = symbolsDict as? [String: [String]] {
            self.symbols = symbols
        }
    }
}
