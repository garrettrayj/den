//
//  FaviconOperation.swift
//  Den
//
//  Created by Garrett Johnson on 7/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

import SwiftSoup

final class MetadataOperation: Operation {
    // Operation inputs
    var webpageUrl: URL?
    var webpageData: Data?

    // Operation outputs
    var defaultFavicon: URL?
    var webpageFavicon: URL?

    override func main() {
        if isCancelled {
            return
        }

        guard let webpage = webpageUrl else {
            return
        }

        if let webpageFaviconUrl = self.getWebpageFavicon(url: webpage, data: webpageData) {
            self.webpageFavicon = webpageFaviconUrl
        }

        if let defaultFaviconUrl = self.getDefaultFavicon(url: webpage) {
            self.defaultFavicon = defaultFaviconUrl
        }
    }

    private func getWebpageFavicon(url: URL, data: Data?) -> URL? {
        guard
            let data = data,
            let htmlString = String(data: data, encoding: .utf8),
            let document = try? SwiftSoup.parse(htmlString)
        else {
            return nil
        }

        guard
            let iconHref = try? document.select("link[rel~=shortcut icon|icon]").attr("href"),
            let faviconURL = URL(string: iconHref, relativeTo: url)
        else {
            return nil
        }

        return faviconURL.absoluteURL
    }

    private func getDefaultFavicon(url: URL) -> URL? {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = "/favicon.ico"
        return components.url
    }
}
