//
//  FeedEditView.swift
//  Den
//
//  Created by Garrett Johnson on 5/23/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import SwiftUI

/**
 FeedOptionsView wrapper for displaying options in a modal sheet.
 */
struct FeedWidgetSettingsView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var mainViewModel: MainViewModel
    
    var pages: FetchedResults<Page>
    
    var body: some View {
        
        if mainViewModel.pageSheetFeed == nil {
            Text("Feed Settings Unavailable")
        } else {
            NavigationView {
                FeedSettingsFormView(
                    subscription: mainViewModel.pageSheetFeed!,
                    pages: pages,
                    onDelete: close,
                    onMove: close
                )
                .navigationTitle("Feed Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar() {
                    ToolbarItem() {
                        Button(action: close) { Text("Close") }
                    }
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    private func close() {
        presentation.wrappedValue.dismiss()
    }
}
