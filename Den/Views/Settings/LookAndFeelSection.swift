//
//  LookAndFeelSection.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct LookAndFeelSection: View {
    @AppStorage("AccentColor") private var accentColor: AccentColor?
    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false
    
    var body: some View {
        Section {
            UserColorSchemePicker(userColorScheme: $userColorScheme)
            AccentColorSelector(selection: $accentColor)
            Toggle(isOn: $useSystemBrowser) {
                Label {
                    Text("Use System Browser", comment: "Toggle label.")
                } icon: {
                    Image(systemName: "arrow.up.right.square")
                }
            }
            Toggle(isOn: $showUnreadCounts) {
                Label {
                    Text("Show Unread Counts", comment: "Toggle label.")
                } icon: {
                    Image(systemName: "3.circle")
                }
            }
        } header: {
            Text("Look & Feel", comment: "Settings section header.")
        }
    }
}
