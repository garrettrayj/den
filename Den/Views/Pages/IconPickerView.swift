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

    @ObservedObject var page: Page

    var symbols: [String: [String]] =  [:]

    let categories: [[String]] = [
        ["uncategorized", "square.grid.2x2", "Uncategorized"],
        ["communication", "bubble.left", "Communication"],
        ["weather", "cloud.sun", "Weather"],
        ["objectsandtools", "folder", "Objects and Tools"],
        ["devices", "desktopcomputer", "Devices"],
        ["connectivity", "antenna.radiowaves.left.and.right", "Connectivity"],
        ["transportation", "car", "Transporation"],
        ["human", "person.crop.circle", "Human"],
        ["nature", "leaf", "Nature"],
        ["editing", "slider.horizontal.3", "Editing"],
        ["commerce", "cart", "Commerce"],
        ["time", "timer", "Time"],
        ["health", "heart", "Health"],
        ["shapes", "square.on.circle", "Shapes"],
        ["arrows", "arrow.right", "Arrows"],
        ["math", "x.squareroot", "Math"]
    ]

    let columns = [
        GridItem(.adaptive(minimum: 32, maximum: 32), spacing: 4, alignment: .top)
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8, pinnedViews: .sectionHeaders) {
                    ForEach(categories, id: \.self) { category in
                        Section(
                            header: Label(category[2], systemImage: category[1])
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .frame(height: 28)
                                .padding(.horizontal)
                                .background(Color(UIColor.tertiarySystemGroupedBackground))
                        ) {
                            LazyVGrid(columns: columns, alignment: .leading, spacing: 4) {
                                ForEach(symbols.keys.sorted(), id: \.self) { key in
                                    if symbols[key]!.contains(category[0]) {
                                        Image(systemName: key)
                                            .imageScale(.medium)
                                            .foregroundColor(key == page.wrappedSymbol ? .accentColor : .primary)
                                            .frame(width: 32, height: 32, alignment: .center)
                                            .background(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(Color(UIColor.secondarySystemGroupedBackground))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4)
                                                    .strokeBorder(
                                                        Color.accentColor,
                                                        lineWidth: key == page.wrappedSymbol ? 2 : 0
                                                    )
                                            )
                                            .onTapGesture {
                                                page.wrappedSymbol = key
                                            }
                                    }
                                }
                            }.padding(.horizontal, 8)
                        }
                    }
                }.padding(.bottom)
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
        .navigationViewStyle(.stack)
    }

    init(page: Page) {
        self.page = page

        guard
            let symbolsPath = Bundle.main.path(forResource: "PageSymbols", ofType: "plist"),
            let symbolsDict = NSDictionary(contentsOfFile: symbolsPath)
        else {
            preconditionFailure("Missing categories configuration")
        }

        if let symbols = symbolsDict as? [String: [String]] {
            self.symbols = symbols
        }
    }
}
