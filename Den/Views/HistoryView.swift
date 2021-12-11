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
    @EnvironmentObject var linkManager: LinkManager

    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.queryIsValid == false {
                Text(viewModel.validationMessage ?? "Invalid search query")
                    .modifier(SimpleMessageModifier())
            } else if viewModel.queryIsValid == true {
                if viewModel.results.count > 0 {
                    resultsList
                } else {
                    if viewModel.query == "" {
                        Text("Empty").modifier(SimpleMessageModifier())
                    } else {
                        Text("No results found").modifier(SimpleMessageModifier())
                    }
                }
            } else {
                resultsList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("History")
    }

    private var resultsList: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(viewModel.results, id: \.self) { resultGroup in
                    if resultGroup.first?.visited != nil {
                        resultsSection(resultGroup: resultGroup)
                    }
                }
            }
        }
    }

    private func resultsSection(resultGroup: [History]) -> some View {
        Section(
            header:
                Text("\(resultGroup.first!.visited!, formatter: DateFormatter.fullNone)")
                    .font(.subheadline)
                    .modifier(PinnedSectionHeaderModifier())
        ) {
            VStack(spacing: 0) {
                ForEach(resultGroup) { result in
                    if result.title != nil && result.link != nil {
                        VStack(alignment: .leading, spacing: 2) {
                            Button { linkManager.openLink(url: result.link) } label: {
                                Text(result.title!)
                                    .font(.title3)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(Color(UIColor.systemPurple))
                            }
                            Text(result.link!.absoluteString)
                                .font(.caption)
                                .foregroundColor(Color.secondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)

                        if resultGroup.last != result {
                            Divider()
                        }
                    }
                }
            }
            .modifier(GroupBlockModifier())
            .padding()
        }
    }
}
