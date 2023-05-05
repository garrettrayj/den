//
//  ViewOptionsSection.swift
//  Den
//
//  Created by Garrett Johnson on 5/5/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ViewOptionsSection: View {
    @Environment(\.useInbuiltBrowser) private var useInbuiltBrowser

    @ObservedObject var feed: Feed

    var body: some View {
        Section {
            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Open in Browser").modifier(FormRowModifier())
                Spacer()
                Toggle("Open in Browser", isOn: $feed.browserView).labelsHidden()
            }
            .modifier(ListRowModifier())
            #else
            Toggle(isOn: $feed.browserView) {
                Text("Open in Browser").modifier(FormRowModifier())
            }
            .modifier(ListRowModifier())
            if feed.browserView {
                Toggle(isOn: $feed.readerMode) {
                    Text("Enter Reader Mode").modifier(FormRowModifier())
                }
                .modifier(ListRowModifier())
            }
            #endif
        } header: {
            Text("Items")
        } footer: {
            #if !targetEnvironment(macCatalyst)
            if useInbuiltBrowser == false {
                Text("System web browser in use. \"Enter Reader Mode\" not applicable.")
            }
            #endif
        }
    }
}
