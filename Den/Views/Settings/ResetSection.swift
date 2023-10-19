//
//  ResetSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ResetSection: View {
    var body: some View {
        Section {
            ClearImageCacheButton()
            ResetEverythingButton()
        } header: {
            Text("Reset", comment: "Section header.")
        }
    }
}
