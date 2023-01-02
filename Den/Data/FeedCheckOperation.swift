//
//  FeedCheckOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/24/21.
//  Copyright © 2021 Garrett Johnson
//

import CoreData
import OSLog

import FeedKit

/**
 Parses fetched feed data with FeedKit
 */
final class FeedCheckOperation: Operation {
    // Operation inputs
    var httpTransportError: Error?
    weak var httpResponse: HTTPURLResponse?
    var data: Data?

    // Operation outputs
    var feedIsValid: Bool = false

    override func main() {
        guard
            httpTransportError == nil,
            let fetchedData = data,
            let httpResponse = self.httpResponse,
            (200...299).contains(httpResponse.statusCode)
        else {
            // Server did not return a well formed HTTP response
            return
        }

        let parserResult = FeedParser(data: fetchedData).parse()

        switch parserResult {
        case .success:
            feedIsValid = true
        case .failure:
            break
        }
    }
}
