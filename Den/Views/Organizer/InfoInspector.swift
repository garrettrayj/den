//
//  InfoInspector.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import UniformTypeIdentifiers

struct InfoInspector: View {
    @Environment(\.openURL) private var openURL

    @ObservedObject var profile: Profile
    @ObservedObject var feed: Feed

    var body: some View {
        List {
            LabeledContent {
                Text(verbatim: "\(feed.urlString)").onDrag {
                    NSItemProvider(object: feed.url?.absoluteString as? NSString ?? "Invalid URL")
                }
            } label: {
                Text("URL", comment: "Diagnostics header.")
            }
            if let feedData = feed.feedData {
                LabeledContent {
                    if feed.isSecure {
                        Image(systemName: feed.urlSchemeSymbol)
                        Text("Yes")
                    } else {
                        Image(systemName: feed.urlSchemeSymbol)
                        Text("No")
                    }
                } label: {
                    Text("Secure", comment: "Diagnostics header.")
                }
                LabeledContent {
                    if let format = feedData.format {
                        Text(verbatim: "\(format)")
                    } else {
                        Text("Not Available")
                    }
                } label: {
                    Text("Format", comment: "Diagnostics header.")
                }
                LabeledContent {
                    if feedData.responseTime > 5 {
                        Image(systemName: "tortoise")
                    }
                    Text("\(Int(feedData.responseTime * 1000)) ms")
                } label: {
                    Text("Response Time", comment: "Diagnostics header.")
                }
                LabeledContent {
                    Text(verbatim: "\(feedData.httpStatus)")
                } label: {
                    Text("Status", comment: "Diagnostics header.")
                }
                LabeledContent {
                    if let ageString = feedData.age, let age = Int(ageString) {
                        Text("\(age) s")
                    } else {
                        Text("Not Available")
                    }
                } label: {
                    Text("Age", comment: "Diagnostics header.")
                }
                LabeledContent {
                    if let cacheControl = feedData.cacheControl {
                        Text(verbatim: "\(cacheControl)")
                    } else {
                        Text("Not Available")
                    }
                } label: {
                    Text("Cache Control", comment: "Diagnostics header.")
                }
                LabeledContent {
                    if let eTag = feedData.eTag {
                        Text(verbatim: "\(eTag)")
                    } else {
                        Text("Not Available")
                    }
                } label: {
                    Text("ETag", comment: "Diagnostics header.")
                }
                LabeledContent {
                    if let server = feedData.server {
                        Text(verbatim: "\(server)")
                    } else {
                        Text("Not Available")
                    }
                } label: {
                    Text("Server", comment: "Diagnostics header.")
                }
            }

            Section {
                if feed.feedData?.format == "JSON" {
                    Button {
                        guard
                            let urlEncoded = feed.urlString.urlEncoded,
                            let validatorURL = URL(
                                string: "https://validator.jsonfeed.org/?url=\(urlEncoded)"
                            )
                        else { return }
                        openURL(validatorURL)
                    } label: {
                        Label {
                            Text("JSON Feed Validator")
                        } icon: {
                            Image(systemName: "stethoscope")
                        }
                    }
                } else {
                    Button {
                        guard
                            let urlEncoded = feed.urlString.urlEncoded,
                            let validatorURL = URL(
                                string: "https://validator.w3.org/feed/check.cgi?url=\(urlEncoded)"
                            )
                        else { return }
                        openURL(validatorURL)
                    } label: {
                        Label {
                            Text("XML Feed Validator")
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
