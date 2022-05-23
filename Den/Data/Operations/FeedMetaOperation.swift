//
//  FeedMetaOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import UIKit

final class FeedMetaOperation: Operation {
    // Operation inputs
    var workingFeed: WorkingFeedData?
    var defaultFaviconResponse: HTTPURLResponse?
    var defaultFaviconData: Data?
    var webpageFaviconResponse: HTTPURLResponse?
    var webpageFaviconData: Data?
    var webpageImages: [RankedImage]?

    override func main() {
        if isCancelled { return }

        // Prefer favicon specified in the feed...
        if workingFeed?.favicon == nil {
            // But fallback to webpage options
            if
                let httpResponse = webpageFaviconResponse,
                let url = checkFavicon(httpResponse: httpResponse)
            {
                self.workingFeed?.favicon = url
            } else if
                let httpResponse = defaultFaviconResponse,
                let url = checkFavicon(httpResponse: httpResponse)
            {
                self.workingFeed?.favicon = url
            }
        }

        if let webpageImages = webpageImages {
            self.workingFeed?.imagePool.append(contentsOf: webpageImages)
        }

        return
    }

    private func checkFavicon(httpResponse: HTTPURLResponse) -> URL? {
        if
            200..<300 ~= httpResponse.statusCode,
            let url = httpResponse.url
        {
            return url
        }

        return nil
    }
}
