
import SwiftUI

struct ChatItem: Identifiable {
    let id = UUID()
    let name: String
    let message: String
    let time: String
}

struct TalkView: View {
    // 💡 検索ワードを保持する状態
    @State private var searchText = ""
    
    // テストデータ
    let chatList = [
        ChatItem(name: "コーヒー好き", message: "おすすめのカフェ教えて！", time: "20:02"),
        ChatItem(name: "カフェ巡りマニア", message: "昨日の豆、美味しかったです！", time: "昨日"),
        ChatItem(name: "バリスタ佐藤", message: "スタンプを送信しました", time: "5月30日"),
        ChatItem(name: "エスプレッソ太郎", message: "ラテアートの練習中ですか？", time: "5月29日"),
        ChatItem(name: "深煎りノマド", message: "コワーキングスペース併設のカフェにいます", time: "5月28日"),
        ChatItem(name: "モカ姉さん", message: "今度の週末、ロースタリー行きません？", time: "5月27日"),
        ChatItem(name: "Coffee_App_Dev", message: "アプリのアップデート完了しました！", time: "5月25日"),
        ChatItem(name: "浅煎りブレンド", message: "フルーティーなエチオピアが入荷したみたい", time: "5月24日"),
        ChatItem(name: "カフェインレス鈴木", message: "デカフェでも美味しいお店見つけました", time: "5月22日"),
        ChatItem(name: "純喫茶めぐり", message: "レトロな喫茶店のプリン最高でした", time: "5月20日")
    ]
    
    // 💡 検索ワードでリストを絞り込む計算プロパティ
    var filteredChatList: [ChatItem] {
        if searchText.isEmpty {
            return chatList
        } else {
            return chatList.filter { $0.name.contains(searchText) }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // --- 💡 ユーザー検索用テキストフィールド ---
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                
                TextField("ユーザーを検索", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            
            // --- トーク一覧 ---
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filteredChatList) { chat in
                        NavigationLink(destination: Text("\(chat.name) とのトーク画面")) {
                            HStack(spacing: 15) {
                                // プロフィール画像
                                ZStack {
                                    Circle().fill(Color.white)
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                
                                // 名前とメッセージ
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(chat.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)
                                    
                                    Text(chat.message)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                // 時間
                                Text(chat.time)
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Divider()
                            .padding(.leading, 80)
                    }
                }
            }
        }
        .background(Color(.systemBackground))
        .navigationTitle("トーク")
    }
}

#Preview {
    NavigationStack {
        TalkView()
    }
}
