//
//  PreviewsSection.swift
//  Den
//
//  Created by Garrett Johnson on 4/27/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewsSection: View {
    @ObservedObject var feed: Feed

    var body: some View {
        Section {
            Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                Text("Item Limit: \(feed.wrappedItemLimit)").modifier(FormRowModifier())
            }
            .onChange(of: feed.wrappedItemLimit, perform: { _ in
                Haptics.lightImpactFeedbackGenerator.impactOccurred()
            })
            .modifier(ListRowModifier())

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
                    Text("Use Reader Mode").modifier(FormRowModifier())
                }
                .modifier(ListRowModifier())
            }
            #endif

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Preferred Style").modifier(FormRowModifier())
                Spacer()
                PreviewStylePicker(previewStyle: $feed.wrappedPreviewStyle)
                    .pickerStyle(.segmented)
                    .scaledToFit()
            }.modifier(ListRowModifier())
            #else
            PreviewStylePicker(previewStyle: $feed.wrappedPreviewStyle).modifier(ListRowModifier())
            #endif

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Hide Images").modifier(FormRowModifier())
                Spacer()
                Toggle("Hide Images", isOn: $feed.hideImages).labelsHidden()
            }
            .modifier(ListRowModifier())
            #else
            Toggle(isOn: $feed.hideImages) {
                Text("Hide Images").modifier(FormRowModifier())
            }
            .modifier(ListRowModifier())
            #endif

            if feed.wrappedPreviewStyle == .expanded {
                #if targetEnvironment(macCatalyst)
                HStack {
                    Text("Hide Teasers").modifier(FormRowModifier())
                    Spacer()
                    Toggle("Hide Teasers", isOn: $feed.hideTeasers).labelsHidden()
                }
                .modifier(ListRowModifier())
                #else
                Toggle(isOn: $feed.hideTeasers) {
                    Text("Hide Teasers").modifier(FormRowModifier())
                }
                .modifier(ListRowModifier())
                #endif
            }
        } header: {
            Text("Previews")
        }
    }
}
