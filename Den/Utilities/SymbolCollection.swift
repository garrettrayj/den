//
//  SymbolCollection.swift
//  Den
//
//  Created by Garrett Johnson on 1/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

class SymbolCollection {
    struct Category: Identifiable {
        var id: String
        var symbol: String
        var title: String
    }

    struct Symbol: Identifiable {
        var id: String
        var categories: [String]
    }

    static let shared = SymbolCollection()

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

    var symbols: [Symbol] =  []

    private init() {
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

    func categorySymbols(categoryID: String) -> [Symbol] {
        return symbols.filter { symbol in
            symbol.categories.contains(categoryID)
        }
    }
}
