//
//  FaviconResultOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import UIKit

import Kingfisher
import func AVFoundation.AVMakeRect

final class SaveFaviconOperation: Operation {
    // Operation inputs
    var workingFeed: WorkingFeedData?
    var webpageFaviconResponse: HTTPURLResponse?
    var webpageFaviconData: Data?
    var defaultFaviconResponse: HTTPURLResponse?
    var defaultFaviconData: Data?

    override func main() {
        if isCancelled { return }

        if
            let httpResponse = webpageFaviconResponse,
            let url = prepareFavicon(httpResponse: httpResponse)
        {
            self.workingFeed?.favicon = url
        } else if
            let httpResponse = defaultFaviconResponse,
            let url = prepareFavicon(httpResponse: httpResponse)
        {
            self.workingFeed?.favicon = url
        }

        return
    }

    private func prepareFavicon(httpResponse: HTTPURLResponse) -> URL? {
        if
            200..<300 ~= httpResponse.statusCode,
            let url = httpResponse.url
        {
            return url
        }

        return nil
    }
}
