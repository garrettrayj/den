//
//  PreviewSettings.swift
//  Den
//
//  Created by Garrett Johnson on 4/27/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewSettings: View {
    @Binding var itemLimit: Int
    @Binding var previewStyle: PreviewStyle
    @Binding var hideImages: Bool
    @Binding var hideTeasers: Bool
    @Binding var browserView: Bool
    @Binding var readerMode: Bool

    var body: some View {
        Stepper(value: $itemLimit, in: 1...100, step: 1) {
            Text("Item Limit: \(itemLimit)").modifier(FormRowModifier())
        }
        .onChange(of: itemLimit, perform: { _ in
            Haptics.lightImpactFeedbackGenerator.impactOccurred()
        })
        .modifier(ListRowModifier())

        #if targetEnvironment(macCatalyst)
        HStack {
            Text("Preferred Style").modifier(FormRowModifier())
            Spacer()
            PreviewStylePicker(previewStyle: $previewStyle).labelsHidden().scaledToFit()
        }.modifier(ListRowModifier())
        #else
        PreviewStylePicker(previewStyle: $previewStyle).modifier(ListRowModifier())
        #endif

        #if targetEnvironment(macCatalyst)
        HStack {
            Text("Hide Images").modifier(FormRowModifier())
            Spacer()
            Toggle("Hide Images", isOn: $hideImages).labelsHidden()
        }
        .modifier(ListRowModifier())
        #else
        Toggle(isOn: $hideImages) {
            Text("Hide Images").modifier(FormRowModifier())
        }
        .modifier(ListRowModifier())
        #endif

        #if targetEnvironment(macCatalyst)
        HStack {
            Text("Hide Teasers").modifier(FormRowModifier())
            Spacer()
            Toggle("Hide Teasers", isOn: $hideTeasers).labelsHidden()
        }
        .modifier(ListRowModifier())
        #else
        Toggle(isOn: $hideTeasers) {
            Text("Hide Teasers").modifier(FormRowModifier())
        }
        .modifier(ListRowModifier())
        #endif

        #if targetEnvironment(macCatalyst)
        HStack {
            Text("Open in Browser").modifier(FormRowModifier())
            Spacer()
            Toggle("Open in Browser", isOn: $browserView).labelsHidden()
        }
        .modifier(ListRowModifier())
        #else
        Toggle(isOn: $browserView) {
            Text("Open in Browser").modifier(FormRowModifier())
        }
        .modifier(ListRowModifier())
        if browserView {
            Toggle(isOn: $readerMode) {
                Text("Use Reader Mode").modifier(FormRowModifier())
            }
            .modifier(ListRowModifier())
        }
        #endif
    }
}
