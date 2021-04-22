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
class DataTaskOperation : AsynchronousOperation {
    var url: URL?
    var data: Data?
    var error: Error?
    var response: HTTPURLResponse?
    
    private var task: URLSessionTask?

    init(_ url: URL? = nil) {
        self.url = url
        super.init()
    }

    override func cancel() {
        task?.cancel()
        super.cancel()
    }

    override func main() {
        guard let requestUrl = url else {
            Logger.ingest.debug("DataTaskOperation missing URL")
            self.finish()
            return
        }
                
        Logger.ingest.info("Downloading \(requestUrl)")
        
        var request = URLRequest(url: requestUrl)
        request.httpShouldHandleCookies = false
        request.timeoutInterval = 30
        
        task = URLSession.shared.dataTask(with: request) { data, response, error in
            self.data = data
            self.error = error
            self.response = response as? HTTPURLResponse
            self.finish()
        }
        task!.resume()
    }
}
