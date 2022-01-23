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

    func resizedToFill(size: CGSize) -> UIImage {
        let scale: CGFloat = max(
            size.width / self.size.width,
            size.height / self.size.height
        )
        let width: CGFloat = self.size.width * scale
        let height: CGFloat = self.size.height * scale
        let boundary = CGRect(
            x: (size.width - width) / 2.0,
            y: (size.height - height) / 2.0,
            width: width,
            height: height
        )

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: boundary)
        }
    }

    func resizedToFit(size: CGSize) -> UIImage {
        let boundary = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(origin: .zero, size: size))

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { (_) in
            self.draw(in: boundary)
        }
    }
}
