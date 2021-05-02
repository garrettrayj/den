//
//  FeedView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

/**
 Block view with channel title and items (articles)
 */
struct FeedWidgetView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var refreshManager: RefreshManager
    @ObservedObject var subscription: Subscription
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 12).fill(Color(.systemBackground))
            widgetContent
        }
    }
    
    var widgetContent: some View {
        VStack(spacing: 0) {
            // MARK: Feed Header
            HStack {
                if subscription.feed?.faviconImage != nil {
                    subscription.feed!.faviconImage!.faviconView()
                }
                Text(subscription.wrappedTitle).font(.headline).lineLimit(1)
                
                Spacer()
                
                Button(action: showOptions) {
                    Image(systemName: "gearshape").faviconView().padding(12)
                }.disabled(refreshManager.refreshing)
            }.padding(.leading, 12)
            
            // MARK: Feed Items
            VStack(spacing: 0) {
                if subscription.feed?.error != nil {
                    Divider()
                    VStack {
                        VStack(spacing: 4) {
                            Text("Unable to update feed")
                                .foregroundColor(.secondary)
                                .font(.callout)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(subscription.feed!.error!)
                                .foregroundColor(.red)
                                .fontWeight(.medium)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(lineWidth: 1)
                            .foregroundColor(.red)
                    )
                    .padding([.horizontal, .top])
                    .padding(.bottom, 2)
                }
                
                if subscription.feed != nil && subscription.feed!.itemsArray.count > 0 {
                    VStack(spacing: 0) {
                        ForEach(subscription.feed!.itemsArray.prefix(subscription.page?.wrappedItemsPerFeed ?? 5)) { item in
                            Group {
                                Divider()
                                FeedWidgetItemRowView(item: item, subscription: subscription)
                            }
                        }
                    }
                } else {
                    if subscription.feed != nil && subscription.feed!.error == nil {
                        Divider()
                    }
                    
                    Text("Feed Empty")
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
    
    func showOptions() {
        self.mainViewModel.pageSheetSubscription = subscription
        self.mainViewModel.pageSheetMode = .feedPreferences
        self.mainViewModel.showingPageSheet = true
    }
}
