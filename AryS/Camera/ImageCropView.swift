//
//  ImageCropView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/21.
//

import SwiftUI

struct ImageCropView: View {
    let inputImage: UIImage
    var aspectRatio: CGFloat = 1.0 // デフォルトは正方形 (1:1)
    var isCircular: Bool = true    // trueなら円形マスク、falseなら長方形マスク
    let onCropped: (UIImage) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    // ジェスチャー用の状態変数
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                GeometryReader { geometry in
                    let screenWidth = geometry.size.width
                    let cropWidth = max(50, screenWidth - 32)
                    let cropHeight = cropWidth / aspectRatio // アスペクト比に応じた高さを計算
                    
                    let imageSize = inputImage.size
                    let initialScale = max(cropWidth / imageSize.width, cropHeight / imageSize.height)
                    let currentScale = initialScale * scale
                    
                    let maxOffsetX = max(0, (imageSize.width * currentScale - cropWidth) / 2)
                    let maxOffsetY = max(0, (imageSize.height * currentScale - cropHeight) / 2)
                    
                    ZStack {
                        // ドラッグ・ピンチ操作対象の画像
                        Image(uiImage: inputImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: imageSize.width, height: imageSize.height)
                            .scaleEffect(currentScale)
                            .offset(
                                x: min(max(offset.width, -maxOffsetX), maxOffsetX),
                                y: min(max(offset.height, -maxOffsetY), maxOffsetY)
                            )
                            .gesture(
                                SimultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            scale = min(max(scale * delta, 1.0), 5.0)
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                offset = clampedOffset(offset, for: currentScale, imageSize: imageSize, cropWidth: cropWidth, cropHeight: cropHeight)
                                            }
                                        },
                                    DragGesture()
                                        .onChanged { value in
                                            let rawOffset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                            offset = clampedOffset(rawOffset, for: currentScale, imageSize: imageSize, cropWidth: cropWidth, cropHeight: cropHeight)
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                            )
                        
                        // マスクオーバーレイ（円形 or 長方形）
                        CropOverlayMask(cropWidth: cropWidth, cropHeight: cropHeight, isCircular: isCircular)
                            .allowsHitTesting(false)
                    }
                    .frame(width: screenWidth, height: geometry.size.height)
                }
            }
            .navigationTitle("写真の調整")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        if let croppedImage = renderCroppedImage() {
                            onCropped(croppedImage)
                        }
                        dismiss()
                    }
                    .bold()
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func clampedOffset(_ offset: CGSize, for currentScale: CGFloat, imageSize: CGSize, cropWidth: CGFloat, cropHeight: CGFloat) -> CGSize {
        let maxOffsetX = max(0, (imageSize.width * currentScale - cropWidth) / 2)
        let maxOffsetY = max(0, (imageSize.height * currentScale - cropHeight) / 2)
        
        return CGSize(
            width: min(max(offset.width, -maxOffsetX), maxOffsetX),
            height: min(max(offset.height, -maxOffsetY), maxOffsetY)
        )
    }
    
    @MainActor
    private func renderCroppedImage() -> UIImage? {
        let imageSize = inputImage.size
        let screenWidth = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width ?? 390
        let cropWidth = screenWidth - 32
        let cropHeight = cropWidth / aspectRatio
        
        let initialScale = max(cropWidth / imageSize.width, cropHeight / imageSize.height)
        let currentScale = initialScale * scale
        let finalOffset = clampedOffset(offset, for: currentScale, imageSize: imageSize, cropWidth: cropWidth, cropHeight: cropHeight)
        
        let renderer = ImageRenderer(content:
            ZStack {
                Image(uiImage: inputImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: imageSize.width, height: imageSize.height)
                    .scaleEffect(currentScale)
                    .offset(finalOffset)
            }
            .frame(width: cropWidth, height: cropHeight)
            .clipped()
        )
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

// マスクオーバーレイビュー（形状切り替え対応）
struct CropOverlayMask: View {
    let cropWidth: CGFloat
    let cropHeight: CGFloat
    let isCircular: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let rect = CGRect(
                x: (size.width - cropWidth) / 2,
                y: (size.height - cropHeight) / 2,
                width: cropWidth,
                height: cropHeight
            )
            
            Path { path in
                path.addRect(CGRect(origin: .zero, size: size))
                if isCircular {
                    path.addEllipse(in: rect)
                } else {
                    path.addRect(rect)
                }
            }
            .fill(style: FillStyle(eoFill: true))
            .foregroundColor(.black.opacity(0.6))
            
            // ガイド枠
            Group {
                if isCircular {
                    Circle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: cropWidth, height: cropWidth)
                        .position(x: size.width / 2, y: size.height / 2)
                } else {
                    Rectangle()
                        .stroke(Color.white, lineWidth: 1)
                        .frame(width: cropWidth, height: cropHeight)
                        .position(x: size.width / 2, y: size.height / 2)
                }
            }
        }
    }
}
