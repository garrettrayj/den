//
//  SidebarPageView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SidebarPageView: View {
    @Environment(\.editMode) private var editMode
    @ObservedObject var page: Page

    var body: some View {
        Label {
            HStack {
                Text(page.displayName)
                    #if targetEnvironment(macCatalyst)
                    .frame(height: 32)
                    .padding(.leading, 6)
                    .font(.system(size: 14))
                    #endif

                Spacer()

                Group {
                    if editMode?.wrappedValue == .inactive {
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
                #if !targetEnvironment(macCatalyst)
                .padding(.trailing, 4)
                #endif

            }.lineLimit(1)
        } icon: {
            Image(systemName: page.wrappedSymbol)
                #if targetEnvironment(macCatalyst)
                .imageScale(.large)
                #endif
        }
    }
}
