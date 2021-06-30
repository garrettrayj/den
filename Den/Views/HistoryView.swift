//
//  HistoryView.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI
import CoreData
import Grid
import OSLog
import Combine

struct HistoryView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var linkManager: LinkManager
    @EnvironmentObject var crashManager: CrashManager
    
    @ObservedObject var mainViewModel: MainViewModel
    
    @State var searchQuery: String = ""
    @State var searchResults: [[History]] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchEntry
                    .padding(.horizontal, 16).padding(.bottom, 12).padding(.top, 12)
                    .background(Color(UIColor.tertiarySystemBackground).edgesIgnoringSafeArea(.all))
                
                if searchResults.count == 0 && searchQuery == "" {
                    Text("History empty or unavailable")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                } else if searchResults.count == 0 && searchQuery != "" {
                    Text("No results found")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                        
                } else {
                    List {
                        ForEach(searchResults, id: \.self) { resultGroup in
                            if resultGroup.first?.visited != nil {
                                Section(
                                    header: Text("\(resultGroup.first!.visited!, formatter: DateFormatter.create(dateStyle: .medium, timeStyle: .none))")
                                ) {
                                    ForEach(resultGroup) { result in
                                        if result.title != nil && result.link != nil {
                                            Button(action: { linkManager.openLink(url: result.link!) }) {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(result.title!).font(.system(size: 18))
                                                    Text(result.link!.absoluteString).font(.caption).foregroundColor(Color.secondary).lineLimit(1)
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup {
                    Button(action: clear) {
                        Text("Clear")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.search(query: searchQuery)
        }
        .onReceive(
            searchQuery
                .publisher
                .removeDuplicates()
                .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                .collect(),
            perform: { _ in
                DispatchQueue.main.async {
                    let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.search(query: trimmedQuery)
                }
            }
        )
        
    }
    
    var searchEntry: some View {
        ZStack {
            HStack {
                TextField(
                    "Search…",
                    text: $searchQuery
                )
                    .font(Font.system(size: 18, design: .default))
                    .frame(height: 40)
                    .background(Color(UIColor.systemBackground))
            }
            .padding(.horizontal, 40)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(12)
            
            HStack {
                Image(systemName: "magnifyingglass")
                    .imageScale(.medium).foregroundColor(.secondary)
                Spacer()
                
                if self.searchQuery != "" {
                    Button(action: reset) {
                        Image(systemName: "multiply.circle.fill")
                            .imageScale(.medium).foregroundColor(Color.secondary)
                    }.layoutPriority(2)
                }
            }
            .padding(.horizontal, 12)
        }
    }
    
    private func reset() {
        self.searchQuery = ""
        self.search(query: "")
    }
    
    private func search(query: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \History.visited, ascending: false)]
        
        if query != "" {
            fetchRequest.predicate = NSPredicate(
                format: "%K CONTAINS[C] %@",
                #keyPath(History.title),
                query
            )
        }
    
        do {
            let fetchResults = try viewContext.fetch(fetchRequest) as! [History]
            var compactedFetchResults: [History] = []
            fetchResults.forEach { history in
                if history.visited != nil {
                    compactedFetchResults.append(history)
                }
            }
            
            let grouping = Dictionary(
                grouping: compactedFetchResults,
                by: { DateFormatter.getFormattedDate(date: $0.visited!, format: "yyyy-MM-dd") }
            )
            
            self.searchResults = grouping.values.sorted { a, b in
                return a[0].visited! > b[0].visited!
            }
        } catch {
            Logger.main.error("Failed to fetch search results: \(error as NSError)")
        }
    }
    
    private func clear() {
        mainViewModel.activeProfile?.historyArray.forEach { history in
            self.viewContext.delete(history)
        }
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
        
        mainViewModel.activeProfile?.pagesArray.forEach({ page in
            page.feedsArray.forEach { feed in
                feed.objectWillChange.send()
            }
        })
        
        reset()
    }
    
}
