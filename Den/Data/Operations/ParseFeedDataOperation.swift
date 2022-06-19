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
final class ParseFeedDataOperation: Operation {
    // Operation inputs
    var httpTransportError: Error?
    var httpResponse: HTTPURLResponse?
    var data: Data?

    // Operation outputs
    var workingFeed: WorkingFeedData = WorkingFeedData()
    var workingItems: [WorkingItem] = []

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

    override func main() {
        guard let fetchedData = data else {
            return
        }

        if let transportError = self.httpTransportError {
            self.workingFeed.error = transportError.localizedDescription
            Logger.ingest.notice("Transport error")
            return
        }

        guard let httpResponse = self.httpResponse else {
            self.workingFeed.error = "Server did not respond"
            Logger.ingest.notice("Server did not respond to request")
            return
        }

        workingFeed.id = self.feedId
        workingFeed.httpStatus = Int(httpResponse.statusCode)

        if !(200...299).contains(workingFeed.httpStatus!) {
            self.workingFeed.error = HTTPURLResponse.localizedString(
                forStatusCode: httpResponse.statusCode
            ).capitalized(with: .autoupdatingCurrent)

            Logger.ingest.notice("""
                Invalid HTTP response: \(httpResponse.statusCode) \(httpResponse.url?.absoluteString ?? "")
            """)
            return
        }

        let parserResult = FeedParser(data: fetchedData).parse()

        switch parserResult {
        case .success(let feed):
            switch feed {
            case let .atom(feed):
                self.handleFeed(feed)
            case let .rss(feed):
                self.handleFeed(feed)
            case let .json(feed):
                self.handleFeed(feed)
            }
        case .failure:
            self.workingFeed.error = "Unable to parse feed"
        }
    }

    private func handleFeed(_ feed: AtomFeed) {
        self.workingFeed.ingest(content: feed)
        handleItems(feed.entries)
    }

    private func handleFeed(_ feed: RSSFeed) {
        workingFeed.ingest(content: feed)
        handleItems(feed.items)
    }

    private func handleFeed(_ feed: JSONFeed) {
        workingFeed.ingest(content: feed)
        handleItems(feed.items)
    }

    private func handleItems(_ items: [ParsedFeedItem]?) {
        guard let items = items, !items.isEmpty else {
            self.workingFeed.error = "Feed empty"
            self.workingFeed.itemCount = 0
            Logger.ingest.notice("Feed empty: \(self.feedUrl)")
            return
        }

        self.workingFeed.itemCount = items.count

        items.forEach { item in
            // Continue if link is missing
            guard let itemLink = item.linkURL else {
                Logger.ingest.notice("Missing link for item.")
                return
            }

            // Continue if item already exists
            if (
                self.existingItemLinks.contains(where: { existingItemLink in
                    existingItemLink == itemLink
                })
            ) {
                return
            }

            let workingItem = WorkingItem()
            workingItem.id = UUID()

            switch type(of: item) {
            case is AtomFeedEntry.Type:
                workingItem.ingest(item as? AtomFeedEntry)
            case is RSSFeedItem.Type:
                workingItem.ingest(item as? RSSFeedItem)
            case is JSONFeedItem.Type:
                workingItem.ingest(item as? JSONFeedItem)
            default:
                assertionFailure("Unknown feed format")
            }

            self.workingItems.append(workingItem)
        }
    }
}
