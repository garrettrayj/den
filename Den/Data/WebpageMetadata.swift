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

class WebpageMetadata {
    struct Results {
        var favicons: [RankedImage] = []
        var icons: [RankedImage] = []
        var banners: [RankedImage] = []
        var description: String?
        var copyright: String?
    }
    
    var webpage: URL
    var webpageDocument: Document?

    init(webpage: URL, data: Data?) {
        self.webpage = webpage
        
        if
            let data = data,
            let htmlString = String(data: data, encoding: .utf8),
            let document = try? SwiftSoup.parse(htmlString)
        {
            webpageDocument = document
        }
    }
    
    var results: Results {
        var metadata = Results()

        if let iconImage = getIconLinkImage(relativeTo: webpage) {
            metadata.favicons.append(RankedImage(url: iconImage, rank: 2))
        } else if let defaultFavicon = getDefaultFavicon(url: webpage) {
            metadata.favicons.append(RankedImage(url: defaultFavicon, rank: 1))
        }

        if let appleTouchIcon = getAppleTouchIcon(relativeTo: webpage) {
            metadata.icons.append(RankedImage(url: appleTouchIcon, rank: 2))
        }

        if let ogImage = getMetaImage(relativeTo: webpage, property: "og:image") {
            metadata.banners.append(RankedImage(url: ogImage, rank: 2))
        }

        if let twitterImage = getMetaImage(relativeTo: webpage, property: "twitter:image") {
            metadata.banners.append(RankedImage(url: twitterImage, rank: 1))
        }

        metadata.description = getMetaContent(property: "description")
        metadata.copyright = getMetaContent(property: "copyright")

        return metadata
    }

    private func getIconLinkImage(relativeTo: URL) -> URL? {
        guard
            let href = try? webpageDocument?.select("link[rel~=shortcut icon|icon]").attr("href"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return url
    }

    private func getAppleTouchIcon(relativeTo: URL) -> URL? {
        guard
            let el = try? webpageDocument?.select("link[rel='apple-touch-icon']"),
            let href = try? el.attr("href"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return url.absoluteURL
    }

    private func getMetaImage(relativeTo: URL, property: String) -> URL? {
        guard
            let el = try? webpageDocument?.select("meta[property='\(property)']"),
            let href = try? el.attr("content"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return url.absoluteURL
    }

    private func getDefaultFavicon(url webpage: URL) -> URL? {
        var components = URLComponents(url: webpage, resolvingAgainstBaseURL: false)!
        components.path = "/favicon.ico"

        if let faviconURL = components.url {
            return faviconURL
        }

        return nil
    }

    private func getMetaContent(property: String) -> String? {
        guard
            let el = try? webpageDocument?.select("meta[name='\(property)']"),
            let content = try? el.attr("content"),
            content != ""
        else {
            return nil
        }

        return content
    }
}
