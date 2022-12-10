//
//  FaviconOperation.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

import SwiftSoup

struct FaviconOperation {
    let webpage: URL

    func execute() async -> URL? {
        guard let (data, _) = try? await URLSession.shared.data(from: webpage) else {
            return nil
        }

        if let favicon = await self.getWebpageFavicon(url: webpage, data: data) {
            return favicon
        } else if let favicon = await self.getDefaultFavicon(url: webpage) {
            return favicon
        }

        return nil
    }

    private func getWebpageFavicon(url: URL, data: Data?) async -> URL? {
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

        return await checkFavicon(url: faviconURL)
    }

    private func getDefaultFavicon(url: URL) async -> URL? {
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        components.path = "/favicon.ico"

        if let faviconURL = components.url {
            return await checkFavicon(url: faviconURL)
        }

        return nil
    }

    private func checkFavicon(url: URL) async -> URL? {
        guard
            let (_, response) = try? await URLSession.shared.data(from: url),
            let httpResponse = response as? HTTPURLResponse,
            200..<300 ~= httpResponse.statusCode,
            let url = httpResponse.url
        else {
            return nil
        }

        return url.absoluteURL
    }

    private func getAppleTouchIcon(document: Document, url: URL) -> RankedImage? {
        guard
            let el = try? document.select("link[rel='apple-touch-icon']"),
            let href = try? el.attr("href"),
            let url = URL(string: href, relativeTo: url)
        else {
            return nil
        }

        return RankedImage(url: url.absoluteURL, rank: 2)
    }

    private func getMetaImage(document: Document, url: URL, property: String) -> RankedImage? {
        guard
            let el = try? document.select("meta[property='\(property)']"),
            let href = try? el.attr("content"),
            let url = URL(string: href, relativeTo: url)
        else {
            return nil
        }

        return RankedImage(url: url, rank: 2)
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
