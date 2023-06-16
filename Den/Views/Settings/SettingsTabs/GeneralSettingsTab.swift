//
//  GeneralSettingsTab.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GeneralSettingsTab: View {
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        VStack {
            UserColorSchemePicker(userColorScheme: $userColorScheme).scaledToFit()
        }.padding()
    }
}
