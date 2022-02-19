//
//  UnreadCountView.swift
//  Den
//
//  Created by Garrett Johnson on 2/19/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct UnreadCountView: View {
    @ObservedObject var page: Page

    var body: some View {
        Text(String(page.unreadCount))
            .font(.caption.weight(.medium))
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .overlay(
                Capsule().fill(Color(UIColor.secondarySystemFill))
            )
    }
}
