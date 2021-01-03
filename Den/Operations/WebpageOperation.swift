//
//  MetadataOperation.swift
//  Den
//
//  Created by Garrett Johnson on 7/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import OSLog

class WebpageOperation : AsynchronousOperation {
    var webpage: URL?
    var data: Data?
    var error: Error?
    
    private var task: URLSessionTask?

    override func cancel() {
        task?.cancel()
        super.cancel()
    }

    override func main() {
        guard let url = webpage else {
            self.finish()
            return
        }
        
        Logger.ingest.debug("Fetching webpage for feed metadata \(url.absoluteString)")
        
        task = URLSession.shared.dataTask(with: url) { data, response, error in
            self.data = data
            self.error = error
            self.finish()
        }
        task!.resume()
    }
}
