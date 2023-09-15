//
//  ArticleTitle.swift
//  Den
//
//  Created by Garrett Johnson on 9/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ArticleTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.largeTitle.weight(.semibold))
            .textSelection(.enabled)
            .padding(.bottom, 4)
    }
}
