//
//  SourceDetail.swift
//  Widget Extension
//
//  Created by Garrett Johnson on 5/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import AppIntents
import CoreData
import SwiftUI

import SDWebImage
import SDWebImageSVGCoder
import SDWebImageWebPCoder

struct SourceDetail: AppEntity {
    let id: UUID
    let entityType: NSManagedObject.Type?
    let title: String
    let symbol: String?
    let faviconData: Data?

    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Source"
    static var defaultQuery = SourceQuery()
            
    var displayRepresentation: DisplayRepresentation {
        if entityType == Page.self {
            if let symbol = symbol {
                DisplayRepresentation(
                    title: "\(title)",
                    subtitle: "Page",
                    image: .init(systemName: symbol)
                )
            } else {
                DisplayRepresentation(
                    title: "\(title)",
                    subtitle: "Page",
                    image: .init(systemName: "folder")
                )
            }
        } else if entityType == Feed.self {
            if let faviconData = faviconData {
                DisplayRepresentation(
                    title: "\(title)",
                    image: .init(data: faviconData)
                )
            } else {
                DisplayRepresentation(
                    title: "\(title)",
                    image: .init(systemName: "dot.radiowaves.up.forward")
                )
            }
        } else {
            if let symbol = symbol {
                DisplayRepresentation(
                    title: "\(title)",
                    subtitle: "All Feeds",
                    image: .init(systemName: symbol)
                )
            } else {
                DisplayRepresentation(title: "\(title)", subtitle: "All Feeds")
            }
        }
    }
    
    static let allSources: [SourceDetail] = {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        
        var sources = [
            SourceDetail(
                id: UUID(uuidString: "866AE799-44C6-48B6-8980-3DC37B18DED7")!,
                entityType: Profile.self,
                title: "Inbox",
                symbol: "tray",
                faviconData: nil
            )
        ]
        
        let context = PersistenceController.shared.container.viewContext
        let request = Page.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)]
        
        if let pages = try? context.fetch(request) {
            for page in pages {
                sources.append(SourceDetail(
                    id: page.id!,
                    entityType: Page.self,
                    title: page.wrappedName,
                    symbol: page.wrappedSymbol, 
                    faviconData: nil
                ))
                
                for feed in page.feedsArray {
                    let dispatchGroup = DispatchGroup()
                    var faviconData: Data?
                    dispatchGroup.enter()
                    SDWebImageManager.shared.loadImage(
                        with: feed.feedData?.favicon,
                        context: [.imageThumbnailPixelSize: CGSize(width: 32, height: 32)],
                        progress: nil
                    ) { _, data, _, _, _, _ in
                        if let data = data {
                            faviconData = data
                        }
                        dispatchGroup.leave()
                    }
                    dispatchGroup.wait()
                    
                    sources.append(SourceDetail(
                        id: feed.id!,
                        entityType: Feed.self,
                        title: feed.wrappedTitle, 
                        symbol: nil,
                        faviconData: faviconData
                    ))
                }
            }
        }
        
        return sources
    }()
}
