//
//  WebpageMetadata.swift
//  Den
//
//  Created by Garrett Johnson on 2/4/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

import SwiftSoup

struct WebpageMetadata {
    var favicons: [RankedImage] = []
    var icons: [RankedImage] = []
    var banners: [RankedImage] = []
    var description: String?
    var copyright: String?

    static func from(webpage: URL, data: Data?) -> WebpageMetadata? {
        guard
            let data = data,
            let htmlString = String(data: data, encoding: .utf8),
            let document = try? SwiftSoup.parse(htmlString)
        else {
            return nil
        }

        var metadata = WebpageMetadata()

        if let iconImage = getIconLinkImage(in: document, relativeTo: webpage) {
            metadata.favicons.append(RankedImage(url: iconImage, rank: 2))
        } else if let defaultFavicon = getDefaultFavicon(url: webpage) {
            metadata.favicons.append(RankedImage(url: defaultFavicon, rank: 1))
        }

        if let appleTouchIcon = getAppleTouchIcon(in: document, relativeTo: webpage) {
            metadata.icons.append(RankedImage(url: appleTouchIcon, rank: 2))
        }

        if let ogImage = getMetaImage(in: document, relativeTo: webpage, property: "og:image") {
            metadata.banners.append(RankedImage(url: ogImage, rank: 2))
        }

        if let twitterImage = getMetaImage(in: document, relativeTo: webpage, property: "twitter:image") {
            metadata.banners.append(RankedImage(url: twitterImage, rank: 1))
        }

        metadata.description = getMetaContent(in: document, property: "description")
        metadata.copyright = getMetaContent(in: document, property: "copyright")

        return metadata
    }

    static private func getIconLinkImage(in document: Document, relativeTo: URL) -> URL? {
        guard
            let href = try? document.select("link[rel~=shortcut icon|icon]").attr("href"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return url
    }

    static private func getAppleTouchIcon(in document: Document, relativeTo: URL) -> URL? {
        guard
            let el = try? document.select("link[rel='apple-touch-icon']"),
            let href = try? el.attr("href"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return url.absoluteURL
    }

    static private func getMetaImage(in document: Document, relativeTo: URL, property: String) -> URL? {
        guard
            let el = try? document.select("meta[property='\(property)']"),
            let href = try? el.attr("content"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return url.absoluteURL
    }

    static private func getDefaultFavicon(url webpage: URL) -> URL? {
        var components = URLComponents(url: webpage, resolvingAgainstBaseURL: false)!
        components.path = "/favicon.ico"

        if let faviconURL = components.url {
            return faviconURL
        }

        return nil
    }

    static private func getMetaContent(in document: Document, property: String) -> String? {
        guard
            let el = try? document.select("meta[name='\(property)']"),
            let content = try? el.attr("content"),
            content != ""
        else {
            return nil
        }

        return content
    }
}
