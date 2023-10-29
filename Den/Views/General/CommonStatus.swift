//
//  CommonStatus.swift
//  Den
//
//  Created by Garrett Johnson on 10/28/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct CommonStatus: View {
    @ObservedObject var profile: Profile
    
    let items: [Item]
    
    var body: some View {
        VStack {
            Group {
                if items.count == 0 {
                    Text("No Items", comment: "Status message.")
                } else if items.unread().count == 0 {
                    Text("All Read", comment: "Status message.")
                } else {
                    Text("\(items.unread().count) Unread", comment: "Status message.")
                }
            }
            .lineLimit(1)
            .font(.caption)
            
            if let refreshedDate = RefreshedDateStorage.getRefreshed(profile) {
                RelativeRefreshedDate(date: refreshedDate)
                    .lineLimit(1)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
