//
//  MetadataOperation.swift
//  Den
//
//  Created by Garrett Johnson on 7/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation

class FetchHomepageOperation : AsynchronousOperation {
    var task: URLSessionTask!
    var homepageData: Data?
    var feed: Feed!

    init(feed: Feed) {
        self.feed = feed
        super.init()
    }

    override func cancel() {
        task.cancel()
        super.cancel()
    }

    override func main() {
        print("Fetching homepage for \(String(describing: self.feed.url))")
        
        guard let homepageURL = feed.link else {
            self.finish()
            return
        }
        
        task = URLSession.shared.dataTask(with: homepageURL) { data, response, error in
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
            
            self.homepageData = data
        }
        
        task.resume()
    }
}
