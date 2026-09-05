//
//  StoreNewsListViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI
import Observation



@Observable
@MainActor
class StoreNewsListViewModel {
    // 仮のNEWSデータ（後でFirestore連携に変更可能）
    var newsList: [News] = [
        News(
            title: "秋限定ブレンド『Autumn Harvest』販売開始のお知らせ",
            subtitle: "深いコクと香ばしいナッツの余韻をお楽しみください。",
            date: "2026/09/01 10:00",
            bodyText: "本日より、秋季限定となる新ブレンドの提供を開始いたしました。季節の変わり目にぴったりの一杯です。",
            linkUrl: "https://example.com/autumn"
        ),
        News(
            title: "営業時間変更のお知らせ（9月）",
            subtitle: "誠に勝手ながら、毎週水曜日を定休日とさせていただきます。",
            date: "2026/08/28 15:30",
            bodyText: "いつもご利用いただきありがとうございます。9月より水曜日が定休日となりますので、ご来店の際はお気をつけください。",
            linkUrl: ""
        )
    ]
    
    func deleteNews(at offsets: IndexSet) {
        newsList.remove(atOffsets: offsets)
    }
}
