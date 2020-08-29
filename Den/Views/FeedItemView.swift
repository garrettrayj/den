//
//  FeedItemView.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import URLImage

/**
 Item (article) row for feeds
 */
struct FeedItemView: View {
    @ObservedObject var item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if item.published != nil {
                Text("\(item.published!, formatter: DateFormatter.create())")
                    .font(.caption)
                    .foregroundColor(Color(UIColor.secondaryLabel))
            }
            
            HStack(alignment: .top) {
                Button(action: openLink) {
                    Text(item.wrappedTitle)
                }
                
                if item.image != nil && item.feed != nil && item.feed!.showThumbnails == true {
                    URLImage(
                        item.image!,
                        processors: [ Resize(size: CGSize(width: 96, height: 64), scale: UIScreen.main.scale) ],
                        placeholder: { _ in
                            VStack {
                                Image(systemName: "photo").foregroundColor(.secondary)
                            }
                            .frame(width: 96, height: 64)
                            .background(Color(UIColor.secondarySystemBackground))
                            .padding(1)
                            .border(Color(UIColor.separator), width: 1)
                        },
                        failure: { _ in
                            VStack {
                                Image(systemName: "exclamationmark.triangle").foregroundColor(.secondary)
                            }
                            .frame(width: 96, height: 64)
                            .background(Color(UIColor.secondarySystemBackground))
                            .padding(1)
                            .border(Color(UIColor.separator), width: 1)
                        },
                        content: { content in
                            ZStack {
                                content.image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 96, height: 64)
                                    .clipped()
                                    .padding(1)
                                    .border(Color(UIColor.separator), width: 1)
                            }
                        }
                    )
                    .frame(width: 96, height: 64)
                }
            }
            
            if item.image != nil && item.feed != nil && item.feed!.showLargePreviews == true {
                URLImage(
                    self.item.image!,
                    content:  {
                        $0.image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .padding(1)
                            .border(Color(UIColor.separator), width: 1)
                    }
                )
                .padding(.top, 4)
            }
        }
        .buttonStyle(ItemLinkButtonStyle(read: $item.read))
        .frame(maxWidth: .infinity)
        .padding(12)
    }
    
    func openLink() {
        DenHosting.nextModalPresentationStyle = .fullScreen
        DenHosting.openSafari(url: item.link!)
        item.markRead()
    }
}
