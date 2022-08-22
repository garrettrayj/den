//
//  SubscriptionManager.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

final class SubscriptionManager: ObservableObject {
    var initialURLString = ""
    var initialPageObjectID: NSManagedObjectID?

    func showSubscribe(for url: URL? = nil, page: Page? = nil) {
        if let url = url {
            let urlString = url.absoluteString
                .replacingOccurrences(of: "feed:", with: "")
                .replacingOccurrences(of: "den:", with: "")

            if var urlComponents = URLComponents(string: urlString) {
                if urlComponents.scheme == nil { urlComponents.scheme = "http" }
                if let urlString = urlComponents.string {
                    initialURLString = urlString
                }
            }
        }

        initialPageObjectID = page?.objectID
        NotificationCenter.default.post(name: .showSubscribe, object: nil)
    }
}
