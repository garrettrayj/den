//
//  FetchOperation.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit
import OSLog

/**
 Operation for fetching feed XML (or JSON) data.
 */
class FetchOperation : AsynchronousOperation {
    var data: Data?
    var error: Error?
    var response: HTTPURLResponse?
    
    private var url: URL
    private var task: URLSessionTask!

    init(url: URL) {
        self.url = url
        super.init()
    
        var request = URLRequest(url: url)
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 30
        
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.data = data
            self.error = error
            self.response = response as? HTTPURLResponse
            self.finish()
        }
    }

    override func cancel() {
        task.cancel()
        super.cancel()
    }

    override func main() {
        Logger.ingest.info("Fetching feed \(self.url)")
        task.resume()
    }
}
