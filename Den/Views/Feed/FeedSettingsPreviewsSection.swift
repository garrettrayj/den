//
//  FeedSettingsPreviewsSection.swift
//  Den
//
//  Created by Garrett Johnson on 4/27/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedSettingsPreviewsSection: View {
    @Environment(\.useSystemBrowser) private var useSystemBrowser

    @ObservedObject var feed: Feed

    @State var showHideTeaserOption: Bool = false

    var body: some View {
        Section {
            Stepper(value: $feed.wrappedItemLimit, in: 1...100, step: 1) {
                Text(
                    "Latest Limit: \(feed.wrappedItemLimit)",
                    comment: "Stepper label."
                )
            }
            #if os(iOS)
            .onChange(of: feed.wrappedItemLimit, perform: { _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            })
            #endif
            
            HStack {
                Text("Preferred Style", comment: "Feed preview style picker label.")
                Spacer()
                PreviewStylePicker(previewStyle: $feed.wrappedPreviewStyle)
                    .pickerStyle(.segmented)
                    .scaledToFit()
                    .labelsHidden()
            }
            .task {
                showHideTeaserOption = feed.wrappedPreviewStyle == .expanded
            }
            .onChange(of: feed.wrappedPreviewStyle) { _ in
                withAnimation {
                    showHideTeaserOption = feed.wrappedPreviewStyle == .expanded
                }
            }

            if showHideTeaserOption {
                Toggle(isOn: $feed.hideTeasers) {
                    Text("Hide Teasers", comment: "Toggle label.")
                }
            }

            Toggle(isOn: $feed.hideBylines) {
                Text("Hide Bylines", comment: "Toggle label.")
            }

            Toggle(isOn: $feed.hideImages) {
                Text("Hide Images", comment: "Toggle label.")
            }
            
            Toggle(isOn: $feed.browserView) {
                Text("Open in Browser", comment: "Toggle label.")
            }

            #if os(iOS)
            if feed.browserView {
                Toggle(isOn: $feed.readerMode) {
                    Text("Enter Reader Mode", comment: "Toggle label.")
                }
            }
            #endif
        } header: {
            Text("Previews")
        } footer: {
            #if os(iOS)
            if useSystemBrowser == true {
                Text(
                    "System web browser in use. \"Enter Reader Mode\" will be ignored.",
                    comment: "Feed settings reader mode guidance note."
                )
            }
            #endif
        }
    }
}
