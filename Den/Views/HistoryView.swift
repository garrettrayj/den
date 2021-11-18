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
            .padding(.top, 8)
        }
    }

    private func resultsSection(resultGroup: [History]) -> some View {
        Section(
            header: Text("\(resultGroup.first!.visited!, formatter: DateFormatter.longNone)")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 4)
                .padding(.horizontal, 20)
                .background(Color(UIColor.secondarySystemBackground))
        ) {
            VStack(spacing: 0) {
                ForEach(resultGroup) { result in
                    if result.title != nil && result.link != nil {
                        VStack(alignment: .leading, spacing: 4) {
                            Button { linkManager.openLink(url: result.link) } label: {
                                Text(result.title!)
                                    .multilineTextAlignment(.leading)
                                    .font(.title3)
                                    .foregroundColor(Color(UIColor.systemPurple))
                            }
                            Text(result.link!.absoluteString)
                                .font(.caption)
                                .foregroundColor(Color.secondary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)

                        if resultGroup.last != result {
                            Divider()
                        }
                    }
                }
            }
            .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground)))
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}
