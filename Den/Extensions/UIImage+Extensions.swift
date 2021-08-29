//
//  UIImage+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/26/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI
import func AVFoundation.AVMakeRect

extension UIImage {
    func resizedToFit(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        let rect = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(origin: .zero, size: size))

        return renderer.image { (_) in
            self.draw(in: CGRect(
                origin: CGPoint(
                    x: size.width / 2 - rect.width / 2,
                    y: size.height / 2 - rect.height / 2
                ),
                size: rect.size
            ))
        }
    }

    func resizedToFill(size: CGSize) -> UIImage? {
        let scale: CGFloat = max(
            size.width / self.size.width,
            size.height / self.size.height
        )
        let width: CGFloat = self.size.width * scale
        let height: CGFloat = self.size.height * scale
        let imageRect = CGRect(
            x: (size.width - width) / 2.0,
            y: (size.height - height) / 2.0,
            width: width,
            height: height
        )

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (_) in
            self.draw(in: imageRect)
        }
    }
}
