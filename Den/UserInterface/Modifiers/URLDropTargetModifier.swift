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
            .onDrop(of: [.url], isTargeted: nil, perform: { providers in
                _ = providers.first?.loadDataRepresentation(for: UTType.url, completionHandler: { [weak page] data, _ in
                    if let data = data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        SubscriptionManager.showSubscribe(for: url, page: page)
                    }
                })
                return true
            })
    }
}
