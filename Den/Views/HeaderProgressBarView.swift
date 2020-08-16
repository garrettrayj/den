//
//  ProgressBarView.swift
//  Den
//
//  Created by Garrett Johnson on 7/28/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import Combine

struct HeaderProgressBarView: View {
    @State var observedProgress: CGFloat = 0
    
    @ObservedObject var updateManager: UpdateManager
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color(UIColor.systemBackground))
                    .frame(width: geometry.size.width, height: 2)
                
                if self.updateManager.updating {
                    Rectangle()
                        .foregroundColor(Color.accentColor)
                        .frame(width: geometry.size.width * self.observedProgress, height: 2)
                        .animation(.linear)
                }
            }
            .onReceive(self.updateManager.progress.publisher(for: \.fractionCompleted).receive(on: RunLoop.main)) { fractionCompleted in
                self.observedProgress = CGFloat(fractionCompleted)
            }
        }
    }
}
