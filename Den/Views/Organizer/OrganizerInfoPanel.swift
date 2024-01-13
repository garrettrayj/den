//
//  OrganizerInfoPanel.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI
import UniformTypeIdentifiers

struct OrganizerInfoPanel: View {
    @Environment(\.openURL) private var openURL
    
    @ObservedObject var profile: Profile
    @ObservedObject var feed: Feed

    var body: some View {
        List {
            LabeledContent {
                Text(verbatim: "\(feed.urlString)")
            } label: {
                Text("URL", comment: "Organizer info panel row label.")
            }
            if let feedData = feed.feedData {
                LabeledContent {
                    if feed.isSecure {
                        Image(systemName: feed.urlSchemeSymbol)
                        Text("Yes", comment: "Boolean value.")
                    } else {
                        Image(systemName: feed.urlSchemeSymbol)
                        Text("No", comment: "Boolean value.")
                    }
                } label: {
                    Text("Secure", comment: "Organizer info panel row label.")
                }
                LabeledContent {
                    if let format = feedData.format {
                        Text(verbatim: "\(format)")
                    } else {
                        Text("Unknown", comment: "Organizer info panel missing data placeholder.")
                    }
                } label: {
                    Text("Format", comment: "Organizer info panel row label.")
                }
                LabeledContent {
                    if feedData.responseTime > 5 {
                        Image(systemName: "tortoise")
                    }
                    Text("\(Int(feedData.responseTime * 1000)) ms", comment: "Milliseconds time display.")
                } label: {
                    Text("Response Time", comment: "Organizer info panel row label.")
                }
                LabeledContent {
                    Text(verbatim: "\(feedData.httpStatus)")
                } label: {
                    Text("Status", comment: "Organizer info panel row label.")
                }
                LabeledContent {
                    if let ageString = feedData.age, let age = Int(ageString) {
                        Text("\(age) s", comment: "Seconds time display.")
                    } else {
                        Text("Unknown", comment: "Organizer info panel missing data placeholder.")
                    }
                } label: {
                    Text("Age", comment: "Organizer info panel row label.")
                }
                LabeledContent {
                    if let cacheControl = feedData.cacheControl {
                        Text(verbatim: "\(cacheControl)")
                    } else {
                        Text("Unknown", comment: "Organizer info panel missing data placeholder.")
                    }
                } label: {
                    Text("Cache Control", comment: "Organizer info panel row label.")
                }
                LabeledContent {
                    if let eTag = feedData.eTag {
                        Text(verbatim: "\(eTag)")
                    } else {
                        Text("Unknown", comment: "Organizer info panel missing data placeholder.")
                    }
                } label: {
                    Text("ETag", comment: "Organizer info panel row label.")
                }
                LabeledContent {
                    if let server = feedData.server {
                        Text(verbatim: "\(server)")
                    } else {
                        Text("Unknown", comment: "Organizer info panel missing data placeholder.")
                    }
                } label: {
                    Text("Server", comment: "Organizer info panel row label.")
                }
            }

            if let validatorURL = feed.validatorURL {
                Section {
                    Button {
                        openURL(validatorURL)
                    } label: {
                        Label {
                            Text("Open Validator", comment: "Button label.")
                        } icon: {
                            Image(systemName: "stethoscope")
                        }
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.inset)
    }
}
