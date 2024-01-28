//
//  PasteboardUtility.swift
//  Den
//
//  Created by Garrett Johnson on 6/23/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct PasteboardUtility {
    static func copyURL(url: URL) {
        #if os(macOS)
        NSPasteboard.general.prepareForNewContents()
        NSPasteboard.general.setString(url.absoluteString, forType: .string)
        #else
        UIPasteboard.general.string = url.absoluteString
        #endif
    }
}
