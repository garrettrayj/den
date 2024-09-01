//
//  UserColorSchemePicker.swift
//  Den
//
//  Created by Garrett Johnson on 6/15/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct UserColorSchemePicker: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        Picker(selection: $userColorScheme) {
            Group {
                Text("System", comment: "User color scheme picker option.")
                    .tag(UserColorScheme.system)
                Text("Light", comment: "User color scheme picker option.")
                    .tag(UserColorScheme.light)
                Text("Dark", comment: "User color scheme picker option.")
                    .tag(UserColorScheme.dark)
            }
            .foregroundStyle(colorScheme == .dark ? .white : .black)
            
        } label: {
            Label {
                Text("Theme", comment: "Picker label.")
            } icon: {
                Image(systemName: "paintpalette")
            }
        }
        #if os(iOS)
        .pickerStyle(.navigationLink)
        #endif
    }
}
