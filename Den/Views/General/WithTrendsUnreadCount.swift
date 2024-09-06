//
//  WithTrendsUnreadCount.swift
//  Den
//
//  Created by Garrett Johnson on 9/5/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct WithTrendsUnreadCount<Content: View>: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var refreshManager: RefreshManager
    
    @ViewBuilder let content: (Int) -> Content
    
    @State private var viewID = UUID()
    
    private var unreadCount: Int {
        let request = Trend.fetchRequest()
        request.predicate = NSPredicate(format: "read = %@", NSNumber(value: false))
        
        return (try? viewContext.count(for: request)) ?? 0
    }

    var body: some View {
        content(unreadCount)
            .id(viewID)
            .onReceive(viewContext.publisher(for: \.hasChanges).filter({ $0 == false })) { _ in
                viewID = UUID()
            }
            .onChange(of: refreshManager.refreshing) {
                if refreshManager.refreshing == false {
                    viewID = UUID()
                }
            }
    }
}
