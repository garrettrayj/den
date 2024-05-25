//
//  GeneralSection.swift
//  Den
//
//  Created by Garrett Johnson on 6/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import BackgroundTasks
import SwiftUI
import WidgetKit

struct GeneralSection: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @EnvironmentObject private var refreshManager: RefreshManager
    
    @AppStorage("AccentColor") private var accentColor: AccentColor?
    @AppStorage("RefreshInterval") private var refreshInterval: RefreshInterval = .zero
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
            .onChange(of: showUnreadCounts) {
                UserDefaults.group.set(showUnreadCounts, forKey: "ShowUnreadCounts")
                WidgetCenter.shared.reloadAllTimelines()
            }
            Toggle(isOn: $useSystemBrowser) {
                Label {
                    Text("Use System Browser", comment: "Toggle label.")
                } icon: {
                    Image(systemName: "arrow.up.right.square")
                }
            }
            Picker(selection: $refreshInterval) {
                ForEach(RefreshInterval.allCases, id: \.self) { interval in
                    if interval == .zero {
                        Text("None", comment: "Empty picker option.").tag(interval)
                    } else {
                        if let formatted = formatter.string(from: TimeInterval(interval.rawValue)) {
                            Text(verbatim: formatted.localizedCapitalized).tag(interval)
                        }
                    }
                }
                // Workaround for iOS navigationLink picker style issue
                .foregroundStyle(colorScheme == .light ? .black : .white)
            } label: {
                Label {
                    Text("Refresh Interval", comment: "Picker label.")
                } icon: {
                    Image(systemName: "timer")
                }
            }
            .onChange(of: refreshInterval) {
                #if os(macOS)
                if refreshInterval == .zero {
                    refreshManager.stopAutoRefresh()
                } else {
                    refreshManager.startAutoRefresh(interval: TimeInterval(refreshInterval.rawValue))
                }
                #else
                BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "net.devsci.den.refresh")
                #endif
            }
            #if os(iOS)
            .pickerStyle(.navigationLink)
            #endif
        } header: {
            Text("General", comment: "Settings section header.")
        } footer: {
            if refreshInterval == .zero {
                Text(
                    """
                    Widgets will update only when feeds are manually refreshed.
                    """,
                    comment: "Refresh settings guidance."
                )
            } else {
                #if os(macOS)
                Text(
                    """
                    Feeds will refresh automatically while the app is running.
                    """,
                    comment: "Refresh settings guidance."
                )
                #else
                Text(
                    """
                    The system decides when background refresh occurs. \
                    Refresh Interval sets the minimum amount of time between background refresh tasks.
                    """,
                    comment: "Refresh settings guidance."
                )
                #endif
            }
        }
    }
}
