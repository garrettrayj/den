//
//  CheckFaviconOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

class CheckFaviconOperation : AsynchronousOperation {
    let acceptableFaviconTypes = ["image/x-icon", "image/vnd.microsoft.icon", "image/png", "image/jpeg"]
    
    var performCheck: Bool = true
    var checkLocation: URL?
    var foundFavicon: URL?
    
    private var task: URLSessionTask?

    override func cancel() {
        task?.cancel()
        super.cancel()
    }

    override func main() {
        guard
            let checkLocation = checkLocation,
            performCheck == true
        else {
            finish()
            return
        }
        
        task = URLSession.shared.dataTask(with: checkLocation) { data, response, error in
            if
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode,
                let mimeType = httpResponse.mimeType,
                self.acceptableFaviconTypes.contains(mimeType),
                let favicon = httpResponse.url
            {
                self.foundFavicon = favicon
            }
            
            self.finish()
        }
        task!.resume()
    }
}
