//
//  URLDropTargetModifier.swift
//  Den
//
//  Created by Garrett Johnson on 9/26/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct URLDropTargetModifier: ViewModifier {
    @ObservedObject var profile: Profile
    
    var page: Page?

    func body(content: Content) -> some View {
        content
            .onDrop(of: [.url, .text], isTargeted: nil, perform: { providers in
                guard let provider: NSItemProvider = providers.first else { return false }

                if provider.canLoadObject(ofClass: URL.self) {
                    _ = provider.loadObject(ofClass: URL.self, completionHandler: { url, _ in
                        NewFeedUtility.showSheet(for: url?.absoluteString, profile: profile, page: page)
                    })
                    return true
                }

                if provider.canLoadObject(ofClass: String.self) {
                    _ = provider.loadObject(ofClass: String.self, completionHandler: { droppedString, _ in
                        NewFeedUtility.showSheet(for: droppedString, profile: profile, page: page)
                    })
                    return true
                }

                return false
            })
    }
}
