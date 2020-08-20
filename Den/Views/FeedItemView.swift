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
    @Environment(\.managedObjectContext) var viewContext
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
                        content:  {
                            $0.image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipped()
                                .overlay(
                                    Rectangle().stroke(lineWidth: 1).foregroundColor(Color(UIColor.separator))
                                )
                    })
                    .frame(width: 96, height: 64)
                    .clipped()
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
                            .overlay(
                                Rectangle().stroke(lineWidth: 1).foregroundColor(Color(UIColor.separator))
                            )
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

struct FeedItemView_Previews: PreviewProvider {
    static var previews: some View {
        FeedItemView(item: Item())
    }
}
