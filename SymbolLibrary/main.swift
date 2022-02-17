//
//  main.swift
//  SymbolLibrary
//
//  Created by Garrett Johnson on 11/20/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

let categoriesPath       = "/Applications/SF Symbols.app/Contents/Resources/categories.plist"
let nameAvailabilityPath = "/Applications/SF Symbols.app/Contents/Resources/name_availability.plist"
let symbolCategoriesPath = "/Applications/SF Symbols.app/Contents/Resources/symbol_categories.plist"

let categories = NSDictionary(contentsOfFile: categoriesPath)
let nameAvailability = NSDictionary(contentsOfFile: nameAvailabilityPath)
let symbolCategories = NSDictionary(contentsOfFile: symbolCategoriesPath)

let outputUrl = URL(fileURLWithPath: "/Users/garrett/Projects/den/Den/Misc/")
    .appendingPathComponent("PageSymbols.plist")

let extraLocaleSuffixes = [".ar", ".he", ".hi", ".ja", ".to", ".ko", ".zh", ".zh.traditional"]
let ignoredCategories = ["indices", "textformatting"]

let excluded = [
    // Restricted
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
    ".inverse",
    "eyedropper.",
    "goforward.",
    "gobackward.",

    // Too Wide
    "person.3.sequence"
]

let included = [
    "person.and.arrow.left.and.arrow.right"
]

public func main() {
    let filtered = filterSymbols()
    let output = NSMutableDictionary(dictionary: filtered)
    output.write(to: outputUrl, atomically: true)
    print(outputUrl)
}

private func filterSymbols() -> [String: [String]] {
    guard
        let symbols = nameAvailability?["symbols"] as? [String: String]
    else {
        preconditionFailure("Symbols not available")
    }

    var categorizedSymbols: [String: [String]] = [:]

    for symbol in symbols {
        let name = symbol.key
        let categories = symbolCategories?[name] as? [String]

        if included.contains(name) {
            categorizedSymbols[name] = categories ?? ["uncategorized"]
            continue
        }

        if excluded.contains(where: name.contains) {
            continue
        }

        if extraLocaleSuffixes.contains(where: name.hasSuffix) {
            continue
        }

        if categories != nil && ignoredCategories.contains(where: categories!.contains) {
            continue
        }

        categorizedSymbols[name] = categories ?? ["uncategorized"]
    }

    return categorizedSymbols
}

main()
