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
    weak var httpResponse: HTTPURLResponse?
    var data: Data?

    // Operation outputs
    var workingFeedData: WorkingFeedData = WorkingFeedData()
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
            self.workingFeedData.error = transportError.localizedDescription
            Logger.ingest.notice("Transport error")
            return
        }

        guard let httpResponse = self.httpResponse else {
            self.workingFeedData.error = "Server did not respond"
            Logger.ingest.notice("Server did not respond to request")
            return
        }

        workingFeedData.id = self.feedId
        workingFeedData.httpStatus = Int(httpResponse.statusCode)

        if !(200...299).contains(workingFeedData.httpStatus!) {
            self.workingFeedData.error = HTTPURLResponse.localizedString(
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
            self.workingFeedData.error = "Unable to parse feed"
        }
    }

    private func handleFeed(_ feed: AtomFeed) {
        self.workingFeedData.ingest(content: feed)
        handleItems(feed.entries)
    }

    private func handleFeed(_ feed: RSSFeed) {
        workingFeedData.ingest(content: feed)
        handleItems(feed.items)
    }

    private func handleFeed(_ feed: JSONFeed) {
        workingFeedData.ingest(content: feed)
        handleItems(feed.items)
    }

    private func handleItems(_ items: [ParsedFeedItem]?) {
        guard let items = items, !items.isEmpty else {
            self.workingFeedData.error = "Feed empty"
            self.workingFeedData.itemCount = 0
            Logger.ingest.notice("Feed empty: \(self.feedUrl)")
            return
        }

        self.workingFeedData.itemCount = items.count

        items.prefix(itemLimit).forEach { item in
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

            workingItem.ingested = Date.now

            // Skip future dated items
            if let published = workingItem.published, published > Date.now {
                return
            }

            self.workingItems.append(workingItem)
        }
    }
}
