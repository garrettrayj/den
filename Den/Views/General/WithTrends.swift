//
//  WithTrends.swift
//  Den
//
//  Created by Garrett Johnson on 1/8/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import CoreData
import SwiftUI

struct WithTrends<Content: View>: View {
    @ViewBuilder let content: ([Trend]) -> Content

    @FetchRequest(sortDescriptors: [])
    private var trends: FetchedResults<Trend>

    var body: some View {
        content(filteredAndSortedTrends)
    }

    init(
        profile: Profile,
        @ViewBuilder content: @escaping ([Trend]) -> Content
    ) {
        self.content = content

        let request: NSFetchRequest<Trend> = Trend.fetchRequest()
        
        if let profileID = profile.id {
            request.predicate = NSPredicate(format: "profileId = %@", profileID as CVarArg)
        } else {
            request.predicate = NSPredicate(format: "1 = 2")
        }
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Trend.title, ascending: true)]
        
        _trends = FetchRequest(fetchRequest: request)
    }
    
    private var filteredAndSortedTrends: [Trend] {
        trends.filter { $0.feeds.count > 1 }
    }
}
