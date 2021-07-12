//
//  ParseOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

import FeedKit

/**
 Parses fetched feed data with FeedKit
 */
final class ParseFeedDataOperation: AsynchronousOperation {
    // Operation inputs
    var httpTransportError: Error?
    var httpResponse: HTTPURLResponse?
    var data: Data?

    // Operation outputs
    var workingFeed: WorkingFeedData = WorkingFeedData()
    var workingItems: [WorkingItem] = []

    private var parser: FeedParser!
    private var feedUrl: URL
    private var itemLimit: Int
    private var existingItemLinks: [URL]
    private var feedId: UUID

    init(feedUrl: URL, itemLimit: Int, existingItemLinks: [URL], feedId: UUID) {
        self.feedUrl = feedUrl
        self.itemLimit = itemLimit
        self.existingItemLinks = existingItemLinks
        self.feedId = feedId
    }

    override func cancel() {
        parser.abortParsing()
        super.cancel()
    }

    override func main() {
        guard let fetchedData = data else {
            self.finish()
            return
        }

        if let transportError = self.httpTransportError {
            self.workingFeed.error = transportError.localizedDescription
            Logger.ingest.notice("Transport error")
            self.finish()
            return
        }

        guard let httpResponse = self.httpResponse else {
            self.workingFeed.error = "Server did not respond"
            Logger.ingest.notice("Server did not respond to request")
            self.finish()
            return
        }

        workingFeed.httpStatus = Int(httpResponse.statusCode)

        if !(200...299).contains(workingFeed.httpStatus!) {
            self.workingFeed.error = HTTPURLResponse.localizedString(
                forStatusCode: httpResponse.statusCode
            ).capitalized(with: .autoupdatingCurrent)

            Logger.ingest.notice("Invalid HTTP response")
            self.finish()
            return
        }

        parser = FeedParser(data: fetchedData)
        parser.parseAsync(queue: .global(qos: .background)) { parserResult in
            defer { self.finish() }

            switch parserResult {
            case .success(let feed):
                switch feed {
                case let .atom(content):
                    self.handleAtomContent(content: content)
                case let .rss(content):
                    self.handleRssContent(content: content)
                case let .json(content):
                    self.handleJsonContent(content: content)
                }
            case .failure(let error):
                self.workingFeed.error = error.localizedDescription
            }
        }
    }

    private func handleAtomContent(content: AtomFeed) {
        guard let atomEntries = content.entries, atomEntries.count > 0 else {
            self.workingFeed.error = "Feed empty"
            Logger.ingest.notice("Atom feed has no items \(self.feedUrl)")
            return
        }

        self.workingFeed.ingest(content: content)
        self.workingFeed.id = self.feedId

        atomEntries.prefix(self.itemLimit).forEach { atomEntry in
            // Continue if link is missing
            guard let itemLink = atomEntry.linkURL else {
                Logger.ingest.notice("Missing link for Atom entry: \(atomEntry.title ?? "Untitled")")
                return
            }

            // Continue if item already exists
            if (self.existingItemLinks.contains(where: { existingItemLink in existingItemLink == itemLink })) {
                return
            }

            let item = WorkingItem()
            item.id = UUID()
            item.ingest(atomEntry)
            self.workingItems.append(item)
        }
    }

    private func handleRssContent(content: RSSFeed) {
        guard let rssItems = content.items, rssItems.count > 0 else {
            self.workingFeed.error = "Feed empty"
            Logger.ingest.notice("Atom feed has no items \(self.feedUrl)")
            return
        }

        self.workingFeed.ingest(content: content)
        self.workingFeed.id = self.feedId

        rssItems.prefix(self.itemLimit).forEach { (rssItem: RSSFeedItem) in
            guard let itemLink = rssItem.linkURL else {
                Logger.ingest.notice("Missing link for RSS item: \(rssItem.title ?? "Untitled")")
                return
            }

            // Continue if item already exists
            if (self.existingItemLinks.contains(where: { existingItemLink in existingItemLink == itemLink })) {
                return
            }

            let item = WorkingItem()
            item.id = UUID()
            item.ingest(rssItem)
            self.workingItems.append(item)
        }
    }

    private func handleJsonContent(content: JSONFeed) {
        guard let jsonItems = content.items, jsonItems.count > 0 else {
            self.workingFeed.error = "Feed empty"
            Logger.ingest.notice("Atom feed has no items \(self.feedUrl)")
            return
        }

        self.workingFeed.ingest(content: content)
        self.workingFeed.id = self.feedId

        jsonItems.prefix(self.itemLimit).forEach { (rssItem: JSONFeedItem) in
            guard let itemLink = rssItem.linkURL else {
                Logger.ingest.notice("Missing link for RSS item: \(rssItem.title ?? "Untitled")")
                return
            }

            // Continue if item already exists
            if (self.existingItemLinks.contains(where: { existingItemLink in existingItemLink == itemLink })) {
                return
            }

            let item = WorkingItem()
            item.ingest(rssItem)
            item.id = UUID()
            self.workingItems.append(item)
        }
    }
}
