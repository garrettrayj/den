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
struct FeedWidgetOptionsView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var mainViewModel: MainViewModel
    
    var pages: FetchedResults<Page>
    
    var body: some View {
        
        if mainViewModel.pageSheetSubscription == nil {
            Text("Feed Options Unavailable")
        } else {
            NavigationView {
                FeedSettingsFormView(
                    subscription: mainViewModel.pageSheetSubscription!,
                    pages: pages,
                    onDelete: close,
                    onMove: close
                )
                .navigationTitle("Feed Options")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar(content: {
                    Button(action: close) { Text("Close") }
                })
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
    
    func close() {
        presentation.wrappedValue.dismiss()
    }
}
