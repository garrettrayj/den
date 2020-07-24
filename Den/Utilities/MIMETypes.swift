//
//  MIMETypes.swift
//  Den
//
//  Created by Garrett Johnson on 7/11/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

struct MIMETypes {
    enum FaviconMIMETypes: String, CaseIterable {
        case icon = "image/x-icon"
        case msicon = "image/vnd.microsoft.icon"
        case png = "image/png"
        case jpg = "image/jpeg"
        case gif = "image/gif"
    }
    
    enum ImageMIMETypes: String, CaseIterable {
        case png = "image/png"
        case jpg = "image/jpeg"
        case gif = "image/gif"
    }
}
