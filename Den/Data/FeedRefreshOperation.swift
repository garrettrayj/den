//
//  FeedRefreshOperation.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData

import FeedKit

struct FeedRefreshOperation {
    let container: NSPersistentContainer
    let feedObjectID: NSManagedObjectID
    let pageObjectID: NSManagedObjectID?
    let url: URL
    let fetchMeta: Bool
    
    func execute() async -> RefreshStatus {
        var refreshStatus = RefreshStatus()
        
        guard let (data, _) = try? await URLSession.shared.data(from: url) else {
            refreshStatus.errors.append("Fetch error")
            return refreshStatus
        }
        
        let parserResult = FeedParser(data: data).parse()
        var webpage: URL? = nil
            
        await container.performBackgroundTask { context in
            guard
                let feed = context.object(with: self.feedObjectID) as? Feed,
                let feedId = feed.id
            else { return }
            
            let feedData = feed.feedData ?? FeedData.create(in: context, feedId: feedId)
            
            switch parserResult {
            case .success(let parsedFeed):
                switch parsedFeed {
                case let .atom(parsedFeed):
                    let updater = AtomFeedUpdate(
                        feed: feed,
                        feedData: feedData,
                        source: parsedFeed,
                        context: context
                    )
                    updater.execute()
                case let .rss(parsedFeed):
                    let updater = RSSFeedUpdate(
                        feed: feed,
                        feedData: feedData,
                        source: parsedFeed,
                        context: context
                    )
                    updater.execute()
                case let .json(parsedFeed):
                    let updater = JSONFeedUpdate(
                        feed: feed,
                        feedData: feedData,
                        source: parsedFeed,
                        context: context
                    )
                    updater.execute()
                }
                webpage = feedData.link
            case .failure:
                refreshStatus.errors.append("Unable to parse feed")
            }
            
            feedData.refreshed = .now
            feedData.error = refreshStatus.errors.first
            
            // Cleanup items
            let maxItems = feed.wrappedItemLimit
            if maxItems > 0 && feedData.itemsArray.count > maxItems {
                feedData.itemsArray.suffix(from: maxItems).forEach { item in
                    feedData.removeFromItems(item)
                    context.delete(item)
                }
            }
            
            for item in feedData.itemsArray {
                item.read = !item.history.isEmpty
            }
             
            try? context.save()
        }
        
        if fetchMeta, let webpage = webpage {
            let faviconOp = FaviconOperation(webpage: webpage)
            
            if let faviconURL = await faviconOp.execute() {
                await container.performBackgroundTask { context in
                    guard
                        let feed = context.object(with: self.feedObjectID) as? Feed,
                        let feedData = feed.feedData
                    else { return }
                    
                    feedData.favicon = faviconURL
                    feedData.metaFetched = .now
                    
                    try? context.save()
                }
            }
        }

        DispatchQueue.main.async {
            NotificationCenter.default.post(
                name: .feedRefreshed,
                object: self.feedObjectID,
                userInfo: ["pageObjectID": pageObjectID as Any]
            )
        }
        return refreshStatus
    }
}
