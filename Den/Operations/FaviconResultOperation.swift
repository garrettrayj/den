//
//  FaviconResultOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import URLImage
import Combine
import func AVFoundation.AVMakeRect


class FaviconResultOperation: AsynchronousOperation {
    var checkedWebpageFavicon: URL?
    var checkedDefaultFavicon: URL?
    var favicon: URL?
    var cancellable: AnyCancellable?
    
    private var faviconSize = CGSize(width: 16, height: 16)
    
    override func cancel() {
        cancellable?.cancel()
        super.cancel()
    }
    
    override func main() {
        if let checkedWebpageFavicon = checkedWebpageFavicon {
            favicon = checkedWebpageFavicon
        } else if let checkedDefaultFavicon = checkedDefaultFavicon {
            favicon = checkedDefaultFavicon
        }
        
        if let faviconUrl = favicon {
            cancellable = URLImageService.shared.remoteImagePublisher(faviconUrl)
                .tryMap { $0.cgImage }
                .catch { _ in
                    Just(nil)
                }
                .sink { image in
                    self.finish()
                }
        } else {
            self.finish()
        }
    }
}
