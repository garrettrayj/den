//
//  NewPageView.swift
//  Den
//
//  Created by Garrett Johnson on 10/1/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct NewPageView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Environment(\.editMode) private var editMode
    
    @ObservedObject var profile: Profile

    var body: some View {
        if editMode?.wrappedValue.isEditing == true {
            Button {
                addPage()
            } label: {
                Label {
                    Text("Add Page")
                } icon: {
                    Image(systemName: "plus.circle")
                }
            }
            .buttonStyle(.borderless)
            .accessibilityIdentifier("new-page-button")
        }
    }

    func addPage() {
        var pageName = "New Page"
        var suffix = 2
        while profile.pagesArray.contains(where: { $0.name == pageName }) {
            pageName = "New Page \(suffix)"
            suffix += 1
        }

        let newPage = Page.create(in: viewContext, profile: profile, prepend: true)
        newPage.wrappedName = pageName

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
