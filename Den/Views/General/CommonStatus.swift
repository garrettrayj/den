//
//  CommonStatus.swift
//  Den
//
//  Created by Garrett Johnson on 10/28/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct CommonStatus: View {
    #if os(iOS)
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    #endif
    
    @ObservedObject var profile: Profile
    
    let items: [Item]
    
    var body: some View {
        #if os(iOS)
        if verticalSizeClass == .compact {
            HStack(spacing: 4) {
                unreadStatus
                Text(verbatim: "-").foregroundStyle(.tertiary)
                if let refreshedDate = RefreshedDateStorage.getRefreshed(profile) {
                    RelativeRefreshedDate(date: refreshedDate)
                        .lineLimit(1)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            VStack {
                unreadStatus
                if let refreshedDate = RefreshedDateStorage.getRefreshed(profile) {
                    RelativeRefreshedDate(date: refreshedDate)
                        .lineLimit(1)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        #endif
    }
    
    private var unreadStatus: some View {
        Group {
            if items.isEmpty {
                Text("No Items", comment: "Status message.")
            } else if items.unread().isEmpty {
                Text("All Read", comment: "Status message.")
            } else {
                Text("\(items.unread().count) Unread", comment: "Status message.")
            }
        }
        .lineLimit(1)
        .font(.caption)
    }
}
