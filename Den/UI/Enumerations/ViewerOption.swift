//
//  ViewerOption.swift
//  Den
//
//  Created by Garrett Johnson on 8/18/24.
//  Copyright © 2024 
//

import Foundation

enum ViewerOption: String {
    case builtInViewer
    case webBrowser
    #if os(iOS)
    case safariView
    #endif
}
