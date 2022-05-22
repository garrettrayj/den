//
//  WebMetaOperation.swift
//  Den
//
//  Created by Garrett Johnson on 7/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

import SwiftSoup

final class WebMetaOperation: Operation {
    // Operation inputs
    var webpageUrl: URL?
    var webpageData: Data?

    // Operation outputs
    var defaultFavicon: URL?
    var webpageFavicon: URL?
    var webpageImages: [RankedImage] = []

    override func main() {
        if isCancelled {
            return
        }

        guard let webpage = webpageUrl else {
            return
        }

        if let defaultFaviconUrl = self.getDefaultFavicon(url: webpage) {
            self.defaultFavicon = defaultFaviconUrl
        }

        if let webpageFaviconUrl = self.getWebpageFavicon(url: webpage, data: webpageData) {
            self.webpageFavicon = webpageFaviconUrl
        }

        webpageImages = self.getWebpageImages(url: webpage, data: webpageData)
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

    private func getAppleTouchIcon(document: Document, url: URL) -> RankedImage? {
        guard
            let el = try? document.select("link[rel='apple-touch-icon']"),
            let href = try? el.attr("href"),
            let url = URL(string: href, relativeTo: url)
        else {
            return nil
        }

        return RankedImage(url: url, rank: 1)
    }

    private func getMetaImage(document: Document, url: URL, property: String) -> RankedImage? {
        guard
            let el = try? document.select("meta[property='\(property)']"),
            let href = try? el.attr("content"),
            let url = URL(string: href, relativeTo: url)
        else {
            return nil
        }

        return RankedImage(url: url, rank: 1)
    }

    private func getWebpageImages(url: URL, data: Data?) -> [RankedImage] {
        var images: [RankedImage] = []

        guard
            let data = data,
            let htmlString = String(data: data, encoding: .utf8),
            let document = try? SwiftSoup.parse(htmlString)
        else {
            return images
        }

        if let appleIcon = getAppleTouchIcon(document: document, url: url) {
            images.append(appleIcon)
        }

        if let ogImage = getMetaImage(document: document, url: url, property: "og:image") {
            images.append(ogImage)
        }

        if let twitterImage = getMetaImage(document: document, url: url, property: "twitter:image") {
            images.append(twitterImage)
        }

        return images
    }
}
