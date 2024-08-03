//
//  DebuggingTools.swift
//  Den
//
//  Created by Garrett Johnson on 5/25/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import OSLog
import SwiftUI

#if os(iOS)
@preconcurrency import BackgroundTasks
#endif

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
                        Text(maintainedDate.formatted())
                    } else {
                        Text("N/A", comment: "Not available.")
                    }
                } label: {
                    Text("Last Run", comment: "Maintenance date label.")
                }
                
                Button {
                    maintenanceInProgress = true
                    Task {
                        await MaintenanceTask.execute()
                        maintenanceInProgress = false
                    }
                } label: {
                    Label {
                        Text("Perform Maintenance", comment: "Button label.")
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
                Text("Maintenance", comment: "Debugging tools section header.")
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
                    EmptyView()
                }
            } header: {
                Text("Background Refresh Status", comment: "Debugging tools section header.")
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
                        or the whole system.
                        """,
                        comment: "Background refresh status guidance."
                    )
                case .available:
                    Text(
                        "Background refresh task is available.",
                        comment: "Background refresh status guidance."
                    )
                @unknown default:
                    EmptyView()
                }
            }
            
            Section {
                if pendingTaskRequests.isEmpty {
                    Text("No Pending Tasks", comment: "Debugging tools message.")
                } else {
                    ForEach(pendingTaskRequests, id: \.self) { request in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(request.identifier)
                            
                            if let date = request.earliestBeginDate {
                                LabeledContent {
                                    Text(date.formatted())
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
                        Text("Cancel", comment: "Button label.")
                    } icon: {
                        Image(systemName: "clear")
                    }
                }
                .disabled(pendingTaskRequests.isEmpty)
            } header: {
                Text("Scheduled Background Tasks", comment: "Debugging tools section header.")
            }
            .task {
                pendingTaskRequests = await BGTaskScheduler.shared.pendingTaskRequests()
            }
            #endif
        }
        .formStyle(.grouped)
        .navigationTitle(Text("Debugging Tools", comment: "Navigation title."))
        .toolbarTitleDisplayMode(.inline)
    }
}
