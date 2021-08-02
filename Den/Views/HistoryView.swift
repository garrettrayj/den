//
//  HistoryView.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var linkManager: LinkManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var searchManager: SearchManager

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchFieldView(isHistorySearchField: true)

                if searchManager.historyResults.count == 0 && searchManager.searchQuery == "" {
                    Text("History is Empty").modifier(SimpleMessageModifier())
                } else if !searchManager.searchIsValid() && searchManager.searchQuery != "" {
                    Text("Minimum Three Characters Required to Search").modifier(SimpleMessageModifier())
                } else if searchManager.historyResults.count == 0 && searchManager.searchQuery != "" {
                    Text("No Results Found").modifier(SimpleMessageModifier())
                } else {
                    resultsList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .onAppear {
                searchManager.performHistorySearch()
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var resultsList: some View {
        List {
            ForEach(searchManager.historyResults, id: \.self) { resultGroup in
                if resultGroup.first?.visited != nil {
                    Section(
                        header: Text("\(resultGroup.first!.visited!, formatter: DateFormatter.mediumNone)")
                    ) {
                        ForEach(resultGroup) { result in
                            if result.title != nil && result.link != nil {
                                Button { linkManager.openLink(url: result.link!) } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.title!).font(.title3)
                                        Text(result.link!.absoluteString)
                                            .font(.caption)
                                            .foregroundColor(Color.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
