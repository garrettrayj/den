//
//  SymbolLibrary.swift
//  Den
//
//  Created by Garrett Johnson on 1/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

class SymbolLibrary {
    struct Symbol: Identifiable {
        let id: String
        let categories: [String]
    }

    static let shared = SymbolLibrary()

    private var symbols: [Symbol] =  []

    private init() {
        guard
            let symbolsPath = Bundle.main.path(forResource: "PageSymbols", ofType: "plist"),
            let symbolsPlist = NSDictionary(contentsOfFile: symbolsPath)
        else {
            preconditionFailure("Symbol categories properties list could not be loaded")
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
