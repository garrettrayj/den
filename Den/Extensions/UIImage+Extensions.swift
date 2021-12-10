//
//  UIImage+Extensions.swift
//  Den
//
//  Created by Garrett Johnson on 8/26/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

extension UIImage {
    /**
     Given a required width, returns a rasterised copy of the image, aspect-fitted to that width.
     */
    func aspectFittedToWidth(_ newWidth: CGFloat) -> UIImage {
        if newWidth > self.size.width {
            return self
        }

        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
