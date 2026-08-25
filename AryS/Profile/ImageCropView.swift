//
//  ImageCropView.swift
//  snsmvvm
//
//  Created by katoso on 2026/08/21.
//

import SwiftUI

struct ImageCropView: View {
    let inputImage: UIImage
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
                    // 画面幅が極端に小さい場合でもマイナスにならないよう安全にガード
                    let cropSize = max(50, screenWidth - 32)
                    
                    let imageSize = inputImage.size
                    let initialScale = min(cropSize / imageSize.width, cropSize / imageSize.height)
                    let currentScale = initialScale * scale
                    
                    let maxOffsetX = max(0, (imageSize.width * currentScale - cropSize) / 2)
                    let maxOffsetY = max(0, (imageSize.height * currentScale - cropSize) / 2)
                    
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
                                    // 拡大縮小
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let delta = value / lastScale
                                            lastScale = value
                                            scale = min(max(scale * delta, 1.0), 5.0)
                                        }
                                        .onEnded { _ in
                                            lastScale = 1.0
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                offset = clampedOffset(offset, for: currentScale, imageSize: imageSize, cropSize: cropSize)
                                            }
                                        },
                                    // 移動
                                    DragGesture()
                                        .onChanged { value in
                                            let rawOffset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                            offset = clampedOffset(rawOffset, for: currentScale, imageSize: imageSize, cropSize: cropSize)
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                        }
                                )
                            )
                        
                        // 外側を暗くして円形をくり抜くマスク
                        CircleMaskOverlay(cropSize: cropSize)
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
    
    // オフセット制限関数
    private func clampedOffset(_ offset: CGSize, for currentScale: CGFloat, imageSize: CGSize, cropSize: CGFloat) -> CGSize {
        let maxOffsetX = max(0, (imageSize.width * currentScale - cropSize) / 2)
        let maxOffsetY = max(0, (imageSize.height * currentScale - cropSize) / 2)
        
        return CGSize(
            width: min(max(offset.width, -maxOffsetX), maxOffsetX),
            height: min(max(offset.height, -maxOffsetY), maxOffsetY)
        )
    }
    
    // 切り抜き処理（画面幅基準の cropSize を動的に計算して合わせる）
    // 切り抜き処理
    @MainActor
    private func renderCroppedImage() -> UIImage? {
        let imageSize = inputImage.size
        
        // 画面幅から cropSize を計算（UIScreenを使わず、GeometryReader等で持たせるか、画面の最小幅を使う方法）
        // ここでは安全にアプリのウィンドウ幅を取得します
        let screenWidth = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.width ?? 390
        let cropSize = screenWidth - 32
        
        let initialScale = min(cropSize / imageSize.width, cropSize / imageSize.height)
        let currentScale = initialScale * scale
        let finalOffset = clampedOffset(offset, for: currentScale, imageSize: imageSize, cropSize: cropSize)
        
        let renderer = ImageRenderer(content:
                                        ZStack {
            Image(uiImage: inputImage)
                .resizable()
                .scaledToFit()
                .frame(width: imageSize.width, height: imageSize.height)
                .scaleEffect(currentScale)
                .offset(finalOffset)
        }
            .frame(width: cropSize, height: cropSize)
            .clipped()
        )
        renderer.scale = 3.0
        return renderer.uiImage
    }
}

// 外側を半透明の黒にして中央の円をくり抜くマスクビュー
struct CircleMaskOverlay: View {
    let cropSize: CGFloat
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            Path { path in
                path.addRect(CGRect(origin: .zero, size: size))
                let circleRect = CGRect(
                    x: (size.width - cropSize) / 2,
                    y: (size.height - cropSize) / 2,
                    width: cropSize,
                    height: cropSize
                )
                path.addEllipse(in: circleRect)
            }
            .fill(style: FillStyle(eoFill: true))
            .foregroundColor(.black.opacity(0.6))
            
            // 円のガイド線
            Circle()
                .stroke(Color.white, lineWidth: 1)
                .frame(width: cropSize, height: cropSize)
                .position(x: size.width / 2, y: size.height / 2)
        }
    }
}
