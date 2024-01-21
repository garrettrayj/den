//
//  ShareButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/18/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct ShareButton: View {
    @Binding var url: URL?

    var body: some View {
        ShareLink(item: url ?? URL(string: "about:blank")!).accessibilityIdentifier("Share")
    }
}
