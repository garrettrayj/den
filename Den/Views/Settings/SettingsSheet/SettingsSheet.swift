//
//  SettingsSheet.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useSystemBrowser: Bool
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if profile.managedObjectContext == nil {
                    SplashNote(title: Text("Profile Deleted", comment: "Object removed message."), symbol: "slash.circle")
                } else {
                    SettingsSheetForm(
                        profile: profile,
                        activeProfile: $activeProfile,
                        appProfileID: $appProfileID,
                        backgroundRefreshEnabled: $backgroundRefreshEnabled,
                        useSystemBrowser: $useSystemBrowser,
                        userColorScheme: $userColorScheme
                    )
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label {
                            Text("Close", comment: "Button label.")
                        } icon: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                    .buttonStyle(.borderless)
                }
            }
            .frame(minWidth: 400, minHeight: 480)
        }
    }
}
