//
//  ResetSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct ResetSection: View {
    var body: some View {
        Section {
            EmptyCachesButton()
            ResetEverythingButton()
        } header: {
            Text("Reset", comment: "Settings section header.")
        }
    }
}
