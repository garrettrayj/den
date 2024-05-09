//
//  GeneralSection.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GeneralSection: View {
    @AppStorage("AccentColor") private var accentColor: AccentColor?
    @AppStorage("AutoRefresh") private var autoRefresh: AutoRefreshInterval = .threeHours
    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false
    
    private let formatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .spellOut
        formatter.allowedUnits = [.hour, .minute]

        return formatter
    }()
    
    var body: some View {
        Section {
            UserColorSchemePicker(userColorScheme: $userColorScheme)
            AccentColorSelector(selection: $accentColor)
            Toggle(isOn: $showUnreadCounts) {
                Label {
                    Text("Show Unread Counts", comment: "Toggle label.")
                } icon: {
                    Image(systemName: "number.circle")
                }
            }
            Toggle(isOn: $useSystemBrowser) {
                Label {
                    Text("Use System Browser", comment: "Toggle label.")
                } icon: {
                    Image(systemName: "arrow.up.right.square")
                }
            }
            Picker(selection: $autoRefresh) {
                ForEach(AutoRefreshInterval.allCases, id: \.self) { interval in
                    if interval == .zero {
                        Text("Off", comment: "Auto refresh disabled.")
                    } else {
                        if let formatted = formatter.string(from: TimeInterval(interval.rawValue)) {
                            Text(
                                "Every \(formatted)",
                                comment: "Auto refresh interval."
                            )
                            .tag(interval)
                        }
                    }
                }
            } label: {
                Label {
                    Text("Auto Refresh", comment: "Picker label.")
                } icon: {
                    Image(systemName: "timer")
                }
            }
        } header: {
            Text("General", comment: "Settings section header.")
        } footer: {
            #if os(macOS)
            if autoRefresh == .zero {
                Text(
                    """
                    Widgets will only update when feeds are manually refreshed.
                    """,
                    comment: "Refresh settings guidance."
                )
            } else {
                Text(
                    """
                    Auto refresh requires the app be running.
                    """,
                    comment: "Refresh settings guidance."
                )
            }
            #else
            if autoRefresh == .zero {
                Text(
                    """
                    Widgets will only update when feeds are manually refreshed.
                    """,
                    comment: "Refresh settings guidance."
                )
                
            } else {
                Text(
                    """
                    The operating system decides when background refresh occurs. \
                    Auto refresh will not happen while the app is active.
                    """,
                    comment: "Refresh settings guidance."
                )
            }
            #endif
        }
    }
}
