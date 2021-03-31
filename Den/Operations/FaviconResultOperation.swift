//
//  FaviconResultOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

class FaviconResultOperation: Operation {
    var checkedWebpageFavicon: URL?
    var checkedDefaultFavicon: URL?
    var favicon: URL?
    
    override func main() {
        if let checkedWebpageFavicon = checkedWebpageFavicon {
            favicon = checkedWebpageFavicon
        } else if let checkedDefaultFavicon = checkedDefaultFavicon {
            favicon = checkedDefaultFavicon
        }
    }
}
