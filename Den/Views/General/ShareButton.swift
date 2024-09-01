//
//  ShareButton.swift
//  Den
//
//  Created by Garrett Johnson on 5/8/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ShareButton: View {
    let item: URL
    
    var body: some View {
        ShareLink(item: item).help(Text("Share", comment: "Button help text."))
    }
}
