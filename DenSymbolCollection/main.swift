//
//  main.swift
//  DenSymbolLib
//
//  Created by Garrett Johnson on 11/20/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

let categoriesPath = "/Applications/SF Symbols.app/Contents/Resources/categories.plist"
let symbolCategoriesPath = "/Applications/SF Symbols.app/Contents/Resources/symbol_categories.plist"

let categories = NSDictionary(contentsOfFile: categoriesPath)
let symbols = NSMutableDictionary(contentsOfFile: symbolCategoriesPath)!

let outputUrl = URL(fileURLWithPath: "/Users/garrett/Projects/den/Den/Misc/")
    .appendingPathComponent("page_symbols.plist")

let extraLocaleSuffixes = [".ar", ".he", ".hi", ".ja", ".to", ".ko", ".zh"]
let ignoredCategories = ["indices", "textformatting", "keyboard"]

let excluded = [
    // Restrictedf
    "airpod",
    "airplay",
    "airport",
    "airtag",
    "applelogo",
    "applescript",
    "appletv",
    "applewatch",
    "arkit",
    "beats",
    "icloud",
    "bonjour",
    "earpods",
    "digitalcrown",
    "faceid",
    "homekit",
    "homepod",
    "ipad",
    "ipod",
    "iphone",
    "livephoto",
    "macmini",
    "macpro",
    "message",
    "pencil.tip",
    "safari",
    "shareplay",
    "swift",
    "teletype",
    "touchid",
    "video",
    "xserve",

    // Logos
    "logo.",

    // Missing
    "bolt.ring.closed",
    "square.3.layers.3d.down.",

    // General Cleanup
    ".fill",
    ".circle",
    ".square",
    ".plus",
    ".minus",
    ".xmark",
    ".inverse"
]

let included = [
    "person.and.arrow.left.and.arrow.right"
]

public func main() {

    let filtered = filterSymbols()
    filtered.write(to: outputUrl, atomically: true)

    print(outputUrl)

    guard let categories = categories else { return }
    print(categories)

}

private func filterSymbols() -> NSMutableDictionary {

    for symbol in symbols {
        guard
            let name = symbol.key as? String,
            let categories = symbol.value as? [String]
        else {
            preconditionFailure("Symbol key could not be cast to string!")
        }

        if included.contains(name) {
            continue
        }

        if excluded.contains(where: name.contains)
            || extraLocaleSuffixes.contains(where: name.suffix(3).contains)
            || ignoredCategories.contains(where: categories.contains) {
            symbols.removeObject(forKey: symbol.key)
        }
    }

    symbols["square.grid.2x2"] = ["uncategorized"]

    return symbols
}

main()
