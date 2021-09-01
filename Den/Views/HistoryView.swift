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

    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchFieldView(
                    query: $viewModel.query,
                    onCommit: viewModel.performHistorySearch,
                    onClear: viewModel.reset
                )

                if viewModel.queryIsValid == false {
                    Text(viewModel.validationMessage ?? "Invalid search query")
                        .modifier(SimpleMessageModifier())
                } else if viewModel.queryIsValid == true {
                    if viewModel.results.count > 0 {
                        resultsList
                    } else {
                        if viewModel.query == "" {
                            Text("No history").modifier(SimpleMessageModifier())
                        } else {
                            Text("No results found").modifier(SimpleMessageModifier())
                        }
                    }
                } else {
                    resultsList
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .onAppear {
                viewModel.performHistorySearch()
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private var resultsList: some View {
        List {
            ForEach(viewModel.results, id: \.self) { resultGroup in
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
