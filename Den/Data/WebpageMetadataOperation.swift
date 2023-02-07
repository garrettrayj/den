//
//  WebpageeMetadataOperation.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

import SwiftSoup

struct WebpageMetadataOperation {
    let webpage: URL

    func execute() async -> WebpageMetadata {
        var metadata = WebpageMetadata()

        guard
            let (data, _) = try? await URLSession.shared.data(from: webpage),
            let htmlString = String(data: data, encoding: .utf8),
            let document = try? SwiftSoup.parse(htmlString)
        else {
            return metadata
        }

        if let iconImage = await getIconLinkImage(in: document, relativeTo: webpage) {
            metadata.favicons.append(RankedImage(url: iconImage, rank: 2))
        } else if let defaultFavicon = await self.getDefaultFavicon(url: webpage) {
            metadata.favicons.append(RankedImage(url: defaultFavicon, rank: 1))
        }

        if let appleTouchIcon = getAppleTouchIcon(in: document, relativeTo: webpage) {
            metadata.icons.append(RankedImage(url: appleTouchIcon, rank: 2))
        }

        if let ogImage = getMetaImage(in: document, relativeTo: webpage, property: "og:image") {
            metadata.banners.append(RankedImage(url: ogImage, rank: 1))
        }

        if let twitterImage = getMetaImage(in: document, relativeTo: webpage, property: "twitter:image") {
            metadata.banners.append(RankedImage(url: twitterImage, rank: 1))
        }

        metadata.description = getMetaContent(in: document, property: "description")
        metadata.copyright = getMetaContent(in: document, property: "copyright")

        return metadata
    }

    private func getIconLinkImage(in document: Document, relativeTo: URL) async -> URL? {
        guard
            let href = try? document.select("link[rel~=shortcut icon|icon]").attr("href"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return await checkImage(url: url)
    }

    private func getAppleTouchIcon(in document: Document, relativeTo: URL) -> URL? {
        guard
            let el = try? document.select("link[rel='apple-touch-icon']"),
            let href = try? el.attr("href"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return url.absoluteURL
    }

    private func getMetaImage(in document: Document, relativeTo: URL, property: String) -> URL? {
        guard
            let el = try? document.select("meta[property='\(property)']"),
            let href = try? el.attr("content"),
            let url = URL(string: href, relativeTo: relativeTo)
        else {
            return nil
        }

        return url.absoluteURL
    }

    private func getDefaultFavicon(url webpage: URL) async -> URL? {
        var components = URLComponents(url: webpage, resolvingAgainstBaseURL: false)!
        components.path = "/favicon.ico"

        if let faviconURL = components.url {
            return await checkImage(url: faviconURL)
        }

        return nil
    }

    private func checkImage(url: URL) async -> URL? {
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

    private func getMetaContent(in document: Document, property: String) -> String? {
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
