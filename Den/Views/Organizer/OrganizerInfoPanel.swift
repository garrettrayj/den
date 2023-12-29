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
                Text("URL", comment: "Info inspector label.")
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
                    Text("Secure", comment: "Info inspector label.")
                }
                LabeledContent {
                    if let format = feedData.format {
                        Text(verbatim: "\(format)")
                    } else {
                        Text("Not Available", comment: "Info missing message.")
                    }
                } label: {
                    Text("Format", comment: "Info inspector label.")
                }
                LabeledContent {
                    if feedData.responseTime > 5 {
                        Image(systemName: "tortoise")
                    }
                    Text("\(Int(feedData.responseTime * 1000)) ms", comment: "Time (milliseconds).")
                } label: {
                    Text("Response Time", comment: "Info inspector label.")
                }
                LabeledContent {
                    Text(verbatim: "\(feedData.httpStatus)")
                } label: {
                    Text("Status", comment: "Info inspector label.")
                }
                LabeledContent {
                    if let ageString = feedData.age, let age = Int(ageString) {
                        Text("\(age) s", comment: "Time (seconds).")
                    } else {
                        Text("Not Available", comment: "Info missing message.")
                    }
                } label: {
                    Text("Age", comment: "Info inspector label.")
                }
                LabeledContent {
                    if let cacheControl = feedData.cacheControl {
                        Text(verbatim: "\(cacheControl)")
                    } else {
                        Text("Not Available", comment: "Info missing message.")
                    }
                } label: {
                    Text("Cache Control", comment: "Info inspector label.")
                }
                LabeledContent {
                    if let eTag = feedData.eTag {
                        Text(verbatim: "\(eTag)")
                    } else {
                        Text("Not Available", comment: "Info missing message.")
                    }
                } label: {
                    Text("ETag", comment: "Info inspector label.")
                }
                LabeledContent {
                    if let server = feedData.server {
                        Text(verbatim: "\(server)")
                    } else {
                        Text("Not Available", comment: "Info missing message.")
                    }
                } label: {
                    Text("Server", comment: "Info inspector label.")
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
