//
//  ClearHistoryButton.swift
//  Den
//
//  Created by Garrett Johnson on 11/27/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct ClearHistoryButton: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var history: FetchedResults<History>

    var body: some View {
        Button {
            for record in history {
                viewContext.delete(record)
            }

            if let items = try? viewContext.fetch(Item.fetchRequest()) {
                items.forEach { $0.read = false }
            }
            
            if let trends = try? viewContext.fetch(Trend.fetchRequest()) {
                trends.forEach { $0.read = false }
            }

            do {
                try viewContext.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        } label: {
            HStack {
                Label {
                    Text("Clear Read History", comment: "Button label.")
                } icon: {
                    Image(systemName: "clear")
                }
                Spacer()
                Group {
                    if history.count == 1 {
                        Text("1 Record", comment: "History count (singular).")
                    } else {
                        Text("\(history.count) Records", comment: "History count (zeor/plural).")
                    }
                }
                .font(.callout)
                .foregroundStyle(.secondary)
            }
        }
        .disabled(history.isEmpty)
        .accessibilityIdentifier("ClearHistory")
    }
}
