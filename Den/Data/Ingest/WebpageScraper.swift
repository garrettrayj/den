//
//  WebpageScraper.swift
//  Den
//
//  Created by Garrett Johnson on 3/16/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import Foundation

import SwiftSoup

struct WebpageScraper {
    static func extractMetadata(webpage: URL, data: Data?) -> WebpageMetadata? {
        guard
            let data = data,
            let htmlString = String(data: data, encoding: .utf8),
            let document = try? SwiftSoup.parse(htmlString)
        else { return nil }

        let metadata = WebpageMetadata()

        if let iconImage = getIconLinkImage(document: document, relativeTo: webpage) {
            metadata.favicons.append(PreliminaryImage(url: iconImage))
        } else if let defaultFavicon = getDefaultFavicon(url: webpage) {
            metadata.favicons.append(PreliminaryImage(url: defaultFavicon))
        }

        if let appleTouchIcon = getAppleTouchIcon(document: document, relativeTo: webpage) {
            metadata.icons.append(PreliminaryImage(url: appleTouchIcon))
        }

        if let ogImage = getMetaImage(document: document, relativeTo: webpage, property: "og:image") {
            metadata.banners.append(PreliminaryImage(url: ogImage))
        }

        if let twitterImage = getMetaImage(
            document: document,
            relativeTo: webpage,
            property: "twitter:image"
        ) {
            metadata.banners.append(PreliminaryImage(url: twitterImage))
        }

        metadata.description = getMetaContent(document: document, property: "description")
        metadata.copyright = getMetaContent(document: document, property: "copyright")

        return metadata
    }

    static private func getIconLinkImage(document: Document, relativeTo: URL) -> URL? {
        guard
            let href = try? document.select("link[rel~=shortcut icon|icon]").attr("href"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return url
    }

    static private func getAppleTouchIcon(document: Document, relativeTo: URL) -> URL? {
        guard
            let element = try? document.select("link[rel='apple-touch-icon']"),
            let href = try? element.attr("href"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return url.absoluteURL
    }

    static private func getMetaImage(document: Document, relativeTo: URL, property: String) -> URL? {
        guard
            let element = try? document.select("meta[property='\(property)']"),
            let href = try? element.attr("content"),
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

    static private func getMetaContent(document: Document, property: String) -> String? {
        guard
            let element = try? document.select("meta[name='\(property)']"),
            let content = try? element.attr("content"),
            content != ""
        else {
            return nil
        }

        return content
    }
}
