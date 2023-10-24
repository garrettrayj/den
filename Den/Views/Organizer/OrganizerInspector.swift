//
//  OrganizerInspector.swift
//  Den
//
//  Created by Garrett Johnson on 9/9/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct OrganizerInspector: View {
    @ObservedObject var profile: Profile

    @Binding var selection: Set<Feed>

    @State private var panel: String = "info"

    var body: some View {
        VStack {
            Picker(selection: $panel) {
                Label {
                    Text("Info", comment: "Inspector panel label.")
                } icon: {
                    Image(systemName: "info.circle")
                }.tag("info")
                Label {
                    Text("Configuration", comment: "Inspector panel label.")
                } icon: {
                    Image(systemName: "slider.horizontal.3")
                }.tag("config")
            } label: {
                Text("View", comment: "Picker label.")
            }
            .labelsHidden()
            .labelStyle(.iconOnly)
            .pickerStyle(.segmented)
            .padding([.horizontal, .top])

            if panel == "info" {
                if selection.count > 1 {
                    Spacer()
                    Text("Multiple Selected", comment: "Inspector selection message.")
                        .font(.title)
                        .foregroundStyle(.tertiary)
                    Spacer()
                } else if let feed = selection.first {
                    OrganizerInfoPanel(profile: profile, feed: feed)
                } else {
                    Spacer()
                    Text("No Selection", comment: "Inspector selection message.")
                        .font(.title)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
            } else if panel == "config" {
                if selection.count > 0 {
                    OrganizerOptionsPanel(profile: profile, selection: $selection)
                } else {
                    Spacer()
                    Text("No Selection", comment: "Inspector selection message.")
                        .font(.title)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
            }
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
        #endif
    }
}
