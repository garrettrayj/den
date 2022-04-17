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
            let data = webpageFaviconData,
            let url = prepareFavicon(httpResponse: httpResponse, data: data)
        {
            self.workingFeed?.favicon = url
        } else if
            let httpResponse = defaultFaviconResponse,
            let data = defaultFaviconData,
            let url = prepareFavicon(httpResponse: httpResponse, data: data)
        {
            self.workingFeed?.favicon = url
        }

        return
    }

    private func prepareFavicon(httpResponse: HTTPURLResponse, data: Data) -> URL? {
        if
            200..<300 ~= httpResponse.statusCode,
            let mimeType = httpResponse.mimeType,
            FaviconMIMEType(rawValue: mimeType) != nil,
            let url = httpResponse.url
        {
            return url
        }

        return nil
    }
}
