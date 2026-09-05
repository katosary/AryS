//
//  CoffeeBeanRangeSliderView.swift
//  AryS
//
//  Created by katoso on 2026/08/30.
//

import SwiftUI

struct CoffeeBeanRangeSliderView: View {
    let minValue: Double = 0.0
    let maxValue: Double = 5.0
    let step: Double = 0.5 // 0.5刻み（必要に応じて 1.0 などに変更してください）
    
    @Binding var lowerRating: Double
    @Binding var upperRating: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // 現在の選択範囲のテキスト表示
            HStack {
                Text("範囲: \(String(format: "%.1f", lowerRating)) 〜 \(String(format: "%.1f", upperRating))")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(.primary)
                Spacer()
            }
            
            // スライダー本体
            GeometryReader { geometry in
                let totalWidth = geometry.size.width
                let thumbSize: CGFloat = 28
                let trackHeight: CGFloat = 24 // コーヒー豆のサイズに合わせる
                
                // 値を座標（幅）に変換
                let valueToX: (Double) -> CGFloat = { value in
                    let percentage = CGFloat((value - minValue) / (maxValue - minValue))
                    return percentage * (totalWidth - thumbSize)
                }
                
                // 座標を値に変換
                let xToValue: (CGFloat) -> Double = { x in
                    let percentage = Double(x / (totalWidth - thumbSize))
                    let rawValue = minValue + percentage * (maxValue - minValue)
                    let stepped = round(rawValue / step) * step
                    return min(max(stepped, minValue), maxValue)
                }
                
                let lowX = valueToX(lowerRating)
                let highX = valueToX(upperRating)
                
                ZStack(alignment: .leading) {
                    // 1. 背景：未選択のコーヒー豆（薄い・線画など）
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image("coffeeBean")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    }
                    .frame(height: trackHeight)
                    
                    // 2. 選択中範囲：塗りつぶしのコーヒー豆（マスクで切り抜く）
                    HStack(spacing: 4) {
                        ForEach(0..<5) { _ in
                            Image("coffeeBeanFill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    }
                    .frame(height: trackHeight)
                    // Amazonスライダーのように選択範囲だけ色を出す・切り抜くマスク処理
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(width: highX) // 右側のつまみの位置まで表示
                        }
                    )
                    // 左側の未選択部分をさらに隠すか、あるいはシンプルに全体の範囲で表現する場合：
                    // より正確に「低〜高」の間だけ光らせたい場合は以下のようにマスクのoffsetXを調整できます
                    
                    // ※ より正確な範囲クリップ用マスク（低〜高の幅だけを表示）
                    let leftOffset = lowX
                    let activeWidth = max(0, highX - lowX + thumbSize)
                    
                    // 3. 視覚的なアクティブレイヤー（低〜高の間だけ塗りつぶし豆を表示）
                    ZStack(alignment: .leading) {
                        HStack(spacing: 4) {
                            ForEach(0..<5) { _ in
                                Image("coffeeBeanFill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                    .frame(width: totalWidth, alignment: .leading)
                    .mask(
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(width: activeWidth)
                                .offset(x: leftOffset)
                        }
                    )
                    
                    // 4. 左側のつまみ（最小値）
                    Circle()
                        .fill(Color(.systemBackground))
                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        .offset(x: lowX)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newX = min(max(0, value.location.x), highX - 20)
                                    lowerRating = xToValue(newX)
                                }
                        )
                    
                    // 5. 右側のつまみ（最大値）
                    Circle()
                        .fill(Color(.systemBackground))
                        .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                        .frame(width: thumbSize, height: thumbSize)
                        .shadow(color: .black.opacity(0.15), radius: 3, x: 0, y: 2)
                        .offset(x: highX)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newX = min(max(lowX + 20, value.location.x), totalWidth - thumbSize)
                                    upperRating = xToValue(newX)
                                }
                        )
                }
            }
            .frame(height: 36)
        }
        .padding(16)
    }
}

