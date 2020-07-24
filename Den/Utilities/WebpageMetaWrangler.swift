//
//  WebpageMetaWrangler.swift
//  Den
//
//  Created by Garrett Johnson on 6/11/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftSoup
import SwiftUI

enum WebpageMetaError: Error {
    case
        invalidUrl,
        dataTaskFailed,
        serverError,
        contentReadFailed,
        parsingFailed,
        invalidFaviconType,
        missingMetaElement,
        invalidPreviewImageType
}

struct WebpageMetaWrangler {
    var webpageURL: URL
    
    let acceptableFaviconTypes = ["image/x-icon", "image/vnd.microsoft.icon", "image/png"]
    let acceptablePreviewImageTypes = ["image/jpeg", "image/png", "image/gif"]

    /**
     Fetches the webpage's favicon, checking document source for icon links first, then falling back to default favicon location.
     Results are validated with an HTTP request that verifies the icon file exists and is of an acceptable type.
     */
    func getFavicon(callback: @escaping (URL?, Error?) -> Void) {
        self.fetchDocument { (document, error) in
            if let error = error {
                return callback(nil, error)
            }
            
            self.getFaviconLink(document: document!) { (faviconURL, error) in
                if let faviconURL = faviconURL {
                    return callback(faviconURL, nil)
                }
                
                self.getDefaultFavicon { (faviconURL, error) in
                    if let faviconURL = faviconURL {
                        return callback(faviconURL, nil)
                    }
                    
                    return callback(nil, nil)
                }
            }
        }
    }
    
    /**
     Extract preview image from HTML. Looks for OpenGraph image meta element.
     */
    func getPreviewImage(callback: @escaping (URL?, Error?) -> Void) {
        self.fetchDocument { (document, error) in
            if let error = error {
                return callback(nil, error)
            }
            
            if var ogImage = try? document!.select("meta[property=og:image]").attr("content") {
                ogImage = ogImage.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard let ogImageURL = URL(string: ogImage, relativeTo: self.webpageURL) else {
                    return callback(nil, WebpageMetaError.invalidUrl)
                }
                
                self.testURL(url: ogImageURL) { (mimeType, error) in
                    if let error = error {
                        return callback(nil, error)
                    }
                    
                    if !self.acceptablePreviewImageTypes.contains(mimeType ?? "") {
                        return callback(nil, WebpageMetaError.invalidPreviewImageType)
                    }
                    
                    return callback(ogImageURL, nil)
                }
            } else {
                return callback(nil, WebpageMetaError.missingMetaElement)
            }
        }
    }
    
    /**
     Extract favicon URL from HTML. Checks for both "icon" and "shortcut icon" relations.
    */
    private func getFaviconLink(document: Document, callback: @escaping (URL?, Error?) -> Void) {
        let faviconLinkSelector = "link[rel~=shortcut icon|icon]"
        
        if var iconHref = try? document.select(faviconLinkSelector).attr("href") {
            iconHref = iconHref.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let faviconURL = URL(string: iconHref, relativeTo: self.webpageURL) else {
                return callback(nil, WebpageMetaError.invalidUrl)
            }
            
            self.testURL(url: faviconURL) { (mimeType, error) in
                if let error = error {
                    return callback(nil, error)
                }
                
                if !self.acceptableFaviconTypes.contains(mimeType ?? "") {
                    return callback(nil, WebpageMetaError.invalidFaviconType)
                }
                
                return callback(faviconURL.absoluteURL, nil)
            }
        } else {
            return callback(nil, WebpageMetaError.missingMetaElement)
        }
    }
    
    /**
     Looks for favicon in default location relative to URL, i.e. original scheme and host with "/favicon.ico" path.
     */
    private func getDefaultFavicon(callback: @escaping (URL?, Error?) -> Void) {
        // Try default favicon location relative to homepage
        var components = URLComponents(url: self.webpageURL, resolvingAgainstBaseURL: false)!
        components.path = "/favicon.ico"
        
        guard let url = components.url else {
            return callback(nil, WebpageMetaError.invalidUrl)
        }
        
        return callback(url, nil)
    }
    
    /**
     Create an HTTP task that fetches a URL and fires callback with SwiftSoup document.
    */
    private func fetchDocument(callback: @escaping (Document?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: self.webpageURL) { data, response, error in
            if error != nil {
                return callback(nil, WebpageMetaError.dataTaskFailed)
            }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                return callback(nil, WebpageMetaError.serverError)
            }
            
            guard
                let mimeType = httpResponse.mimeType,
                mimeType == "text/html",
                let data = data,
                let string = String(data: data, encoding: .utf8)
            else {
                return callback(nil, WebpageMetaError.contentReadFailed)
            }
            
            guard let document: Document = try? SwiftSoup.parse(string) else {
                return callback(nil, WebpageMetaError.parsingFailed)
            }
            
            callback(document, nil)
        }
        task.resume()
    }
    
    /**
     Create an HTTP task that fetches a URL and fires callback with MIME type string.
     */
    private func testURL(url: URL, callback: @escaping (String?, Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        let checkTask = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                return callback(nil, WebpageMetaError.dataTaskFailed)
            }
            
            guard
                let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode)
            else {
                return callback(nil, WebpageMetaError.serverError)
            }
            
            guard let mimeType = httpResponse.mimeType else {
                return callback(nil, WebpageMetaError.contentReadFailed)
            }
            
            callback(mimeType, nil)
        }
        
        checkTask.resume()
    }
}
