//
//  HTMLCleaner.swift
//  Den
//
//  Created by Garrett Johnson on 6/11/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftSoup

struct HTMLCleaner {
    static func stripTags(_ input: String) -> String? {
        guard let doc: Document = try? SwiftSoup.parseBodyFragment(input) else { return nil } // parse html
        guard let txt = try? doc.text() else { return nil }

        return txt
    }
}
