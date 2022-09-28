//
//  URLDropTargetModifier.swift
//  Den
//
//  Created by Garrett Johnson on 9/26/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct URLDropTargetModifier: ViewModifier {
    var page: Page?

    func body(content: Content) -> some View {
        content
            .onDrop(of: [.url, .text], isTargeted: nil, perform: { providers in
                guard let provider: NSItemProvider = providers.first else { return false }

                if provider.canLoadObject(ofClass: URL.self) {
                    _ = provider.loadObject(ofClass: URL.self, completionHandler: { url, _ in
                        SubscriptionManager.showSubscribe(for: url, page: page)
                    })
                    return true
                }

                if provider.canLoadObject(ofClass: String.self) {
                    _ = provider.loadObject(ofClass: String.self, completionHandler: { droppedString, _ in
                        if let droppedString = droppedString, let url = URL(string: droppedString) {
                            SubscriptionManager.showSubscribe(for: url, page: page)
                        }
                    })
                    return true
                }

                return false
            })
    }
}
