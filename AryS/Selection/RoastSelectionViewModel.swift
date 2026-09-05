//
//  RoastSelectionViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/19.
//

import Observation
import SwiftUI

@Observable
class RoastSelectionViewModel {
    var selectedRoast: String = "ライトロースト" // 初期値
    var isShowingRoastPicker: Bool = false
    
    let roastLevels = [
        "ライトロースト", "シナモンロースト",
        "ミディアムロースト", "ハイロースト",
        "シティロースト", "フルシティロースト",
        "フレンチロースト", "イタリアンロースト"
    ]
}
