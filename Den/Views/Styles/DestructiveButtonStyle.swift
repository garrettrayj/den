//
//  DeleteButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 7/11/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI


struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: ButtonStyle.Configuration) -> some View {
        DestructiveButton(configuration: configuration)
    }

    private struct DestructiveButton: View {
        let configuration: ButtonStyle.Configuration

        @Environment(\.isEnabled) private var isEnabled: Bool
        
        var body: some View {
            configuration.label
                .foregroundColor(labelColor(isEnabled: isEnabled))
                .opacity(configuration.isPressed ? 0.6 : 1.0)
        }
        
        private func labelColor(isEnabled: Bool) -> Color {
            if isEnabled == true {
                return Color(UIColor.systemRed)
            }
            
            return Color.secondary
        }
    }
}
