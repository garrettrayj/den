//
//  FaviconOperation.swift
//  Den
//
//  Created by Garrett Johnson on 7/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftSoup

class ParseMetadataOperation : AsynchronousOperation {
    var task: URLSessionTask!
    var feed: Feed!
    var homepageData: Data?
    
    let acceptableFaviconTypes = ["image/x-icon", "image/vnd.microsoft.icon", "image/png", "image/jpeg"]

    init(feed: Feed) {
        self.feed = feed
        super.init()
    }

    override func main() {
        print("Parsing feed from \(String(describing: self.feed.url))")
        
        guard let homepageURL = feed.link else {
            print("Homepage URL required for favicon operation")
            self.finish()
            return
        }
        
        let defaultFaviconURL = self.getDefaultFavicon(homepage: homepageURL)
        let webpageFaviconURL = self.getWebpageFavicon(homepage: homepageURL, data: homepageData)

        // First check for webpage favicon, then fallback on default favicon location
        self.checkFaviconLocation(faviconURL: webpageFaviconURL) { faviconURL in
            if let faviconURL = faviconURL {
                // Favicon found in homepage icon <link>
                self.feed.favicon = faviconURL
                self.finish()
            } else {
                self.checkFaviconLocation(faviconURL: defaultFaviconURL) { faviconURL in
                    if let faviconURL = faviconURL {
                        // Default favicon found
                        self.feed.favicon = faviconURL
                    }
                    self.finish()
                }
            }
        }
    }
    
    func checkFaviconLocation(faviconURL: URL?, callback: @escaping (URL?) -> Void) {
        guard let faviconURL = faviconURL else {
            return callback(nil)
        }
        
        task = URLSession.shared.dataTask(with: faviconURL) { data, response, error in
            if
                let httpResponse = response as? HTTPURLResponse,
                200..<300 ~= httpResponse.statusCode,
                let mimeType = httpResponse.mimeType,
                self.acceptableFaviconTypes.contains(mimeType)
            {
                callback(faviconURL)
                return
            }
            
            callback(nil)
        }
        task.resume()
    }
    
    func getWebpageFavicon(homepage: URL, data: Data?) -> URL? {
        guard
            let data = data,
            let htmlString = String(data: data, encoding: .utf8),
            let document = try? SwiftSoup.parse(htmlString)
        else {
            return nil
        }
        
        guard
            let iconHref = try? document.select("link[rel~=shortcut icon|icon]").attr("href"),
            let faviconURL = URL(string: iconHref, relativeTo: homepage)
        else {
            return nil
        }
        
        return faviconURL.absoluteURL
    }
    
    func getDefaultFavicon(homepage: URL) -> URL? {
        var components = URLComponents(url: homepage, resolvingAgainstBaseURL: false)!
        components.path = "/favicon.ico"
        return components.url
    }
}
