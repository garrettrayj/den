//
//  FetchOperation.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

/**
 Operation for fetching feed XML (or JSON) data.
 */
class FetchFeedOperation : AsynchronousOperation {
    var task: URLSessionTask!
    var feedData: Data?

    init(session: URLSession, url: URL) {
        super.init()

        task = session.dataTask(with: url) { data, response, error in
            defer { self.finish() }

            guard
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode,
                let data = data
            else {
                // handle invalid return codes however you'd like
                self.finish()
                return
            }
            
            self.feedData = data
        }
    }

    override func cancel() {
        task.cancel()
        super.cancel()
    }

    override func main() {
        print("Fetching \(String(describing: task.originalRequest?.url))")
        task.resume()
    }
}
