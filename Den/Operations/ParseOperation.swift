//
//  ParseOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit

/**
 Operation for fetching feed XML (or JSON) data.
 */
class ParseOperation : AsynchronousOperation {
    var data: Data?
    var parsedFeed: FeedKit.Feed?
    var error: FeedKit.ParserError?
    
    private var parser: FeedParser!

    override func cancel() {
        parser.abortParsing()
        super.cancel()
    }

    override func main() {
        guard let fetchedData = data else {
            self.finish()
            return
        }
        
        parser = FeedParser(data: fetchedData)
        parser.parseAsync(queue: .global(qos: .background)) { parserResult in
            defer { self.finish() }
        
            switch parserResult {
            case .success(let feed):
                self.parsedFeed = feed
            case .failure(let error):
                self.error = error
            }
        }
    }
}
