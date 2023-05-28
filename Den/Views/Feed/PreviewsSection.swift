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
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    @ObservedObject var feed: Feed

    @State var showHideTeaserOption: Bool = false

    var body: some View {
        Section {
            HStack {
                Text("Preferred Style").modifier(FormRowModifier())
                Spacer()
                PreviewStylePicker(previewStyle: $feed.wrappedPreviewStyle)
                    .pickerStyle(.segmented)
                    .scaledToFit()
            }
            .modifier(ListRowModifier())
            .task {
                showHideTeaserOption = feed.wrappedPreviewStyle == .expanded
            }
            .onChange(of: feed.wrappedPreviewStyle) { _ in
                withAnimation {
                    showHideTeaserOption = feed.wrappedPreviewStyle == .expanded
                }
            }

            if showHideTeaserOption {
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

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Hide Bylines").modifier(FormRowModifier())
                Spacer()
                Toggle("Hide Bylines", isOn: $feed.hideBylines).labelsHidden()
            }
            .modifier(ListRowModifier())
            #else
            Toggle(isOn: $feed.hideBylines) {
                Text("Hide Bylines").modifier(FormRowModifier())
            }
            .modifier(ListRowModifier())
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
            Text("Previews")
        } footer: {
            #if !targetEnvironment(macCatalyst)
            if useSystemBrowser == true {
                Text("System web browser in use. \"Enter Reader Mode\" will be ignored.")
            }
            #endif
        }
    }
}
