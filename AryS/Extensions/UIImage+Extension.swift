//
//  UIImage+Extension.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/21.
//

import UIKit

extension UIImage {
    
    /// 指定した長辺のピクセルサイズにアスペクト比を維持してリサイズするメソッド
    func resize(toMaxLongSide longSide: CGFloat = 1080.0) -> UIImage? {
        let aspectRatio = self.size.width / self.size.height
        var newSize: CGSize
        
        if self.size.width > self.size.height {
            newSize = CGSize(width: longSide, height: longSide / aspectRatio)
        } else {
            newSize = CGSize(width: longSide * aspectRatio, height: longSide)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
