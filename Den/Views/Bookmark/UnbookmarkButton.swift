//
//  UnbookmarkButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/17/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct UnbookmarkButton: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var bookmark: Bookmark
    
    var callback: (() -> Void)?

    var body: some View {
        Button(role: .destructive) {
            viewContext.delete(bookmark)
            do {
                try viewContext.save()
                callback?()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        } label: {
            Label {
                Text("Unbookmark", comment: "Button label.")
            } icon: {
                Image(systemName: "bookmark").symbolVariant(.slash)
            }
        }
        .help(Text("Remove bookmark", comment: "Button help text."))
        .accessibilityIdentifier("Unbookmark")
    }
}
