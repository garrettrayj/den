//
//  BrowserSettingsSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 12/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BrowserSettingsSectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @Binding var useInbuiltBrowser: Bool

    var body: some View {
        Section {
            Toggle(isOn: $useInbuiltBrowser) {
                Text("Use Inbuilt Browser")
            }
        } header: {
            Text("Links")
        }
    }
}

