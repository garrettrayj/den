//
//  OrganizerInfoPanel.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct OrganizerInfoPanel: View {
    @ObservedObject var feed: Feed

    var body: some View {
        List {
            LabeledContent {
                Text(feed.urlString)
            } label: {
                Text("URL", comment: "Organizer info panel row label.")
            }
            if let feedData = feed.feedData {
                LabeledContent {
                    HStack {
                        if feed.isSecure {
                            Image(systemName: feed.urlSchemeSymbol)
                            Text("Yes", comment: "Boolean value.")
                        } else {
                            Image(systemName: feed.urlSchemeSymbol)
                            Text("No", comment: "Boolean value.")
                        }
                    }
                } label: {
                    Text("Secure", comment: "Organizer info panel row label.")
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
                    Text(verbatim: """
                    \(feedData.httpStatus) \
                    \(
                        HTTPURLResponse.localizedString(
                            forStatusCode: Int(feedData.httpStatus)
                        ).localizedCapitalized
                    )
                    """)
                } label: {
                    Text("Status", comment: "Organizer info panel row label.")
                }
                
                if let format = feedData.format {
                    LabeledContent {
                        Text(format)
                    } label: {
                        Text("Format", comment: "Organizer info panel row label.")
                    }
                }
                
                if let ageString = feedData.age, let age = Int(ageString) {
                    LabeledContent {
                        Text("\(age) s", comment: "Seconds time display.")
                    } label: {
                        Text("Age", comment: "Organizer info panel row label.")
                    }
                }
                
                if let cacheControl = feedData.cacheControl {
                    LabeledContent {
                        Text(cacheControl)
                    } label: {
                        Text("Cache Control", comment: "Organizer info panel row label.")
                    }
                }
                
                if let eTag = feedData.eTag {
                    LabeledContent {
                        Text(eTag)
                    } label: {
                        Text("ETag", comment: "Organizer info panel row label.")
                    }
                }
                
                if let server = feedData.server {
                    LabeledContent {
                        Text(server)
                    } label: {
                        Text("Server", comment: "Organizer info panel row label.")
                    }
                }
            }
            
            if let validatorURL = feed.validatorURL {
                Section {
                    OpenValidatorButton(url: validatorURL)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .listStyle(.inset)
    }
}
