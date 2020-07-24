//
//  ParseOperation.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import FeedKit


class ParseFeedOperation : AsynchronousOperation {
    var feedData: Data?
    var feed: Feed!

    init(feed: Feed) {
        super.init()
        self.feed = feed
    }

    override func cancel() {
        //task.cancel()
        super.cancel()
    }

    override func main() {
        print("Parsing feed from \(String(describing: self.feed.url))")
        
        guard let data = feedData else {
            print("Missing data for parse")
            self.finish()
            return
        }
        
        let parser = FeedParser(data: data)
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            self.feed.handleResult(result)
            self.finish()
        }
    }

}
