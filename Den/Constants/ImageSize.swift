//
//  ImageSize.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ImageSize {
    static let favicon = CGSize(width: 16, height: 16)

    #if targetEnvironment(macCatalyst)
    static let thumbnail = CGSize(width: 84, height: 56)
    #else
    static let thumbnail = CGSize(width: 102, height: 68)
    #endif

    static let preview = CGSize(width: 396, height: 264)
}
