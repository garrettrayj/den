//
//  Search+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 8/24/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

@objc(Search)
final public class Search: NSManagedObject {
    var wrappedQuery: String {
        query ?? ""
    }

    static func create(
        in managedObjectContext: NSManagedObjectContext,
        query: String
    ) -> Search {
        let search = self.init(context: managedObjectContext)
        search.id = UUID()
        search.submitted = Date()
        search.query = query

        return search
    }
}
