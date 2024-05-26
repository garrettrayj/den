//
//  DebuggingTools.swift
//  Den
//
//  Created by Garrett Johnson on 5/25/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import BackgroundTasks
import OSLog
import SwiftUI

struct DebuggingTools: View {
    @Environment(\.displayScale) private var displayScale
    
    @AppStorage("Maintained") var maintained: Double?
    
    #if os(iOS)
    @State private var pendingTaskRequests: [BGTaskRequest] = []
    #endif
    @State private var maintenanceInProgress = false
    
    var maintainedDate: Date? {
        if let maintained {
            Date(timeIntervalSince1970: maintained)
        } else {
            nil
        }
    }
    
    var body: some View {
        Form {
            Section {
                LabeledContent {
                    if let maintainedDate {
                        Text("\(maintainedDate.formatted())")
                    } else {
                        Text("N/A")
                    }
                } label: {
                    Text("Last Run")
                }
                
                Button {
                    maintenanceInProgress = true
                    Task {
                        await MaintenanceTask().execute()
                        maintenanceInProgress = false
                    }
                } label: {
                    Label {
                        Text("Perform Maintenance")
                    } icon: {
                        if maintenanceInProgress {
                            ProgressView().progressViewStyle(.circular)
                                #if os(macOS)
                                .scaleEffect(1/displayScale)
                                #endif
                        } else {
                            Image(systemName: "wrench.and.screwdriver")
                        }
                    }
                }
            } header: {
                Text("Maintenance", comment: "Debug info section header.")
            }
            
            #if os(iOS)
            Section {
                switch UIApplication.shared.backgroundRefreshStatus {
                case .restricted:
                    Text("Restricted", comment: "Background refresh status.")
                case .denied:
                    Text("Denied", comment: "Background refresh status.")
                case .available:
                    Text("Available", comment: "Background refresh status.")
                @unknown default:
                    Text("Unknown")
                }
            } header: {
                Text("Background Refresh Status")
            } footer: {
                switch UIApplication.shared.backgroundRefreshStatus {
                case .restricted:
                    Text(
                        "Background updates are unavailable and the user cannot enable them again.",
                        comment: "Background refresh status guidance."
                    )
                case .denied:
                    Text(
                        """
                        Background behavior has been explicitly disabled for this app \
                        or the whole system. Maintenance and refresh tasks are unavailable.
                        """,
                        comment: "Background refresh status guidance."
                    )
                case .available:
                    Text(
                        "Background maintenance and refresh tasks are available.",
                        comment: "Background refresh status guidance."
                    )
                @unknown default:
                    Text(verbatim: "")
                }
            }
            
            Section {
                if pendingTaskRequests.isEmpty {
                    Text("No Pending Tasks", comment: "Debugging tools message.")
                } else {
                    ForEach(pendingTaskRequests, id: \.self) { request in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(verbatim: "\(request.identifier)")
                            
                            if let date = request.earliestBeginDate {
                                LabeledContent {
                                    Text(verbatim: "\(date.formatted())")
                                } label: {
                                    Text("Earliest Begin Date", comment: "Content label.")
                                }
                                .font(.footnote)
                            }
                        }
                    }
                }
                
                Button {
                    BGTaskScheduler.shared.cancelAllTaskRequests()
                    pendingTaskRequests = []
                } label: {
                    Label {
                        Text("Cancel All", comment: "Button label.")
                    } icon: {
                        Image(systemName: "clear")
                    }
                }
                .disabled(pendingTaskRequests.isEmpty)
            } header: {
                Text("Scheduled Background Tasks", comment: "Debug info section header.")
            }
            .task {
                pendingTaskRequests = await BGTaskScheduler.shared.pendingTaskRequests()
            }
            #endif
        }
        .navigationTitle(Text("Debugging Tools", comment: "Navigation title."))
        .toolbarTitleDisplayMode(.inline)
    }
}
