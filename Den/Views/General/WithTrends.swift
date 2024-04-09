//
//  WithTrends.swift
//  Den
//
//  Created by Garrett Johnson on 1/8/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct WithTrends<Content: View>: View {
    @ViewBuilder let content: (FetchedResults<Trend>) -> Content

    @FetchRequest(sortDescriptors: [])
    private var trends: FetchedResults<Trend>

    var body: some View {
        content(trends)
    }

    init(
        @ViewBuilder content: @escaping (FetchedResults<Trend>) -> Content
    ) {
        self.content = content

        let request: NSFetchRequest<Trend> = Trend.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Trend.title, ascending: true)]
        
        _trends = FetchRequest(fetchRequest: request)
    }
}
