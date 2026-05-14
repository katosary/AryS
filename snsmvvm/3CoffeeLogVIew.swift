//
//  SendMessageView.swift
//  snsmvvm
//
//  Created by katoso on 2026/02/28.
//

import SwiftUI
import PhotosUI

struct SelectShopView : View {
    // --- 追加: 環境から ViewModel を取得 ---
    @Environment(ViewModel.self) var viewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    
    var body: some View {
        VStack(spacing: 30) {
            Text("どこで飲んだコーヒーですか？")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 20)
            
            // カフェを探すボタン
            // これで viewModel と profileViewModel がこのスコープ内で使えるようになります
            NavigationLink(destination: ShopLogView()) {
                SearchMenuButton(title: "カフェ", subtitle: "お近くの店舗", icon: "mappin.and.ellipse", color: .orange)
            }
            
            // オンラインショップを探すボタン
            NavigationLink(destination: OnlineShopLogView()) {
                SearchMenuButton(title: "オンラインショップ", subtitle: "お家で楽しむアイテム", icon: "cart.fill", color: .blue)
            }
            
            Spacer()
        }
        .padding(20)
        .navigationTitle("検索")
    }
}


struct ShopLogView: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var currentStep: Int = 0
    private let totalSteps = 7
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $currentStep) {
                    stepInfoPage().tag(0)
                    stepPhotoPage().tag(1)
                    stepAromaPage().tag(2)
                    stepFirstPage().tag(3)
                    stepSecondPage().tag(4)
                    confirmationPage().tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // --- 下部のナビゲーションボタン ---
                navigationControls()
            }
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func navigationControls() -> some View {
        HStack {
            if currentStep > 0 {
                Button("戻る") {
                    withAnimation { currentStep -= 1 }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            if currentStep < totalSteps - 1 {
                Button("次へ") {
                    withAnimation { currentStep += 1 }
                }
                .buttonStyle(.borderedProminent)
                // STEP 1 で生産国が未選択なら「次へ」を押せなくする等のバリデーション
                .disabled(currentStep == 0 && viewModel.countryName.isEmpty)
            }
        }
        .padding()
        .background(.ultraThinMaterial) // 境目をわかりやすく
    }
    
    // MARK: - 各ページを ViewBuilder で分離（エラー回避の肝）
    
    @ViewBuilder
    private func stepInfoPage() -> some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 20) {
            Text("これから飲むコーヒーのことを教えてください").font(.headline)
            editField(label: "店舗名", text: $viewModel.shopName, placeholder: "店舗名を入力してください")
            
            // ボタンとして表示し、タップでシートを起動
            Button(action: {
                viewModel.isShowingCountryPicker = true
            }) {
                HStack {
                    Text("生産国")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(viewModel.countryName.isEmpty ? "選択してください" : viewModel.countryName)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            // シートの定義
            .sheet(isPresented: $viewModel.isShowingCountryPicker) {
                CountrySelectionView(viewModel: viewModel)
            }
            TextField("農園名", text: $viewModel.farmName)
                .textFieldStyle(.roundedBorder)
            // ボタンとして表示し、タップでシートを起動
            Button(action: {
                viewModel.isShowingRoastPicker = true
            }) {
                HStack {
                    Text("焙煎度")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(viewModel.roastLevel.isEmpty ? "選択してください" : viewModel.roastLevel)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            // シートの定義
            .sheet(isPresented: $viewModel.isShowingRoastPicker) {
                RoastSelectionView(viewModel: viewModel)
            }
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepPhotoPage() -> some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 20) {
            Text("目の前のコーヒーの写真を撮ってください").font(.headline)
            if let image = viewModel.logImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 250)
                    .overlay(Image(systemName: "photo").font(.largeTitle))
            }
            
            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                Label(viewModel.logImage == nil ? "画像を選択" : "画像を変更", systemImage: "photo")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepAromaPage() -> some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 30) {
            Text("STEP１. 香りを楽しみましょう").font(.headline)
            VStack {
                Text("香りは感じましたか？").padding(5)
                HStack {
                    Text("弱い").padding(5)
                    HStack {
                        ForEach(1...viewModel.maxRating, id: \.self) { number in
                            viewModel.image(for: number, rating: viewModel.aromarating)
                                .font(.system(size: 30))
                                .foregroundColor(number > viewModel.aromarating ? viewModel.offColor : viewModel.onColor)
                                .onTapGesture { viewModel.aromarating = number }
                        }
                    }
                    Text("強い").padding(5)
                }
                Text("どんな香りでしたか？\n(任意)").padding(10)
                TextField("香りの種類", text: $viewModel.aromaComment)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
            }
            Divider()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepFirstPage() -> some View {
        VStack(spacing: 30) {
            Text("STEP2. １口目の感想を教えてください").font(.headline)
            HStack {
                Text("苦味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bitternessrating1)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bitternessrating1 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bitternessrating1 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("酸味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.acidityrating1)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.acidityrating1 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.acidityrating1 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("コク")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bodyrating1)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bodyrating1 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bodyrating1 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepSecondPage() -> some View {
        VStack(spacing: 30) {
            Text("STEP3. 2口目の感想を教えてください").font(.headline)
            HStack {
                Text("苦味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bitternessrating2)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bitternessrating2 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bitternessrating2 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("酸味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.acidityrating2)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.acidityrating2 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.acidityrating2 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("コク")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bodyrating2)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bodyrating2 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bodyrating2 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
        }
        .padding()
        
    }
    
    @ViewBuilder
    private func confirmationPage() -> some View {
        VStack(spacing: 20) {
            Text("表示位置を調整してください").font(.headline)
            Text("アイコンをドラッグして、味のポジションを微調整できます。").font(.caption).foregroundColor(.secondary)
            // プレビュー用のカードを表示
            // ここではまだ投稿前なので、現在入力中のデータから一時的な Log を生成して表示します
            if let previewLog = createPreviewLog() {
                PostCardView(log: previewLog, viewModel: viewModel,profileViewModel: profileViewModel,isEditable: true)
                    .frame(height: 400) // プレビューに適したサイズに調整
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
        }
        //---投稿ボタン　※最後のページに貼り付ける ---
        Button {
            viewModel.addLog(currentUser: profileViewModel.user)
            viewModel.aromarating = 0
            dismiss()
        } label: {
            Text("この内容で投稿する")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.aromarating == 0 ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(viewModel.aromarating == 0)
        Spacer()
    }
    
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String, isMultiLine: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                // 見出しラベル
                Text(label)
                    .font(.body)
                    .frame(width: 100, alignment: .leading)
                    .padding(.vertical, 12)
                
                // 入力欄
                if isMultiLine {
                    // 複数行の場合
                    TextField(placeholder, text: text, axis: .vertical)
                        .font(.body)
                        .lineLimit(3...6) // 3行〜6行
                        .padding(.vertical, 12)
                } else {
                    // 1行の場合
                    TextField(placeholder, text: text)
                        .font(.body)
                        .lineLimit(1) // 1行固定
                        .padding(.vertical, 12)
                }
            }
            
            Divider()
                .padding(.leading, 0) // 必要に応じてラベルの末尾から線を開始させるなら調整
        }
    }
    
    // 入力中のデータからプレビュー用モデルを作成する補助関数
    private func createPreviewLog() -> Log? {
        return Log(
            user: profileViewModel.user,
            shopName: viewModel.shopName,
            countryName: viewModel.countryName,
            farmName: viewModel.farmName,
            roastLevel: viewModel.roastLevel,
            aromarating: viewModel.aromarating,
            aromaComment: viewModel.aromaComment,
            bitternessrating1: viewModel.bitternessrating1,
            acidityrating1: viewModel.acidityrating1,
            bodyrating1: viewModel.bodyrating1,
            bitternessrating2: viewModel.bitternessrating2,
            acidityrating2: viewModel.acidityrating2,
            bodyrating2: viewModel.bodyrating2,
            createdAt: Date(),
            logImage: viewModel.logImage,
            textOffset: CGSize(width: viewModel.currentOffsetX, height: viewModel.currentOffsetY)
        )
    }
    
    
    //    @ViewBuilder
    //    private func navigationControls() -> some View {
    //        HStack {
    //            if currentStep > 0 {
    //                Button("戻る") {
    //                    withAnimation { currentStep -= 1 }
    //                }
    //            }
    //            Spacer()
    //            if currentStep < totalSteps - 1 {
    //                Button("次へ") {
    //                    withAnimation { currentStep += 1 }
    //                }
    //                .buttonStyle(.borderedProminent)
    //                .disabled(currentStep == 0 && viewModel.countryName.isEmpty)
    //            }
    //        }
    //        .padding()
    //    }
}

struct OnlineShopLogView: View {
    @Environment(ViewModel.self) var viewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    @Environment(\.dismiss) private var dismiss
    
    
    @State private var currentStep: Int = 0
    private let totalSteps = 6
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                TabView(selection: $currentStep) {
                    stepInfoPage().tag(0)
                    stepPhotoPage().tag(1)
                    stepAromaPage().tag(2)
                    stepFirstPage().tag(3)
                    stepSecondPage().tag(4)
                    confirmationPage().tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // --- 下部のナビゲーションボタン ---
                navigationControls()
            }
            .navigationTitle("新規投稿")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    @ViewBuilder
    private func navigationControls() -> some View {
        HStack {
            if currentStep > 0 {
                Button("戻る") {
                    withAnimation { currentStep -= 1 }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            if currentStep < totalSteps - 1 {
                Button("次へ") {
                    withAnimation { currentStep += 1 }
                }
                .buttonStyle(.borderedProminent)
                // STEP 1 で生産国が未選択なら「次へ」を押せなくする等のバリデーション
                .disabled(currentStep == 0 && viewModel.countryName.isEmpty)
            }
        }
        .padding()
        .background(.ultraThinMaterial) // 境目をわかりやすく
    }
    
    // MARK: - 各ページを ViewBuilder で分離（エラー回避の肝）
    
    @ViewBuilder
    private func stepInfoPage() -> some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 20) {
            Text("これから飲むコーヒーのことを教えてください").font(.headline)
            editField(label: "店舗名", text: $viewModel.shopName, placeholder: "店舗名を入力してください")
            
            // ボタンとして表示し、タップでシートを起動
            Button(action: {
                viewModel.isShowingCountryPicker = true
            }) {
                HStack {
                    Text("生産国")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(viewModel.countryName.isEmpty ? "選択してください" : viewModel.countryName)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            // シートの定義
            .sheet(isPresented: $viewModel.isShowingCountryPicker) {
                CountrySelectionView(viewModel: viewModel)
            }
            TextField("農園名", text: $viewModel.farmName)
                .textFieldStyle(.roundedBorder)
            // ボタンとして表示し、タップでシートを起動
            Button(action: {
                viewModel.isShowingRoastPicker = true
            }) {
                HStack {
                    Text("焙煎度")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(viewModel.roastLevel.isEmpty ? "選択してください" : viewModel.roastLevel)
                        .foregroundColor(.secondary)
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            // シートの定義
            .sheet(isPresented: $viewModel.isShowingRoastPicker) {
                RoastSelectionView(viewModel: viewModel)
            }
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepPhotoPage() -> some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 20) {
            Text("目の前のコーヒーの写真を撮ってください").font(.headline)
            if let image = viewModel.logImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 250)
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.secondary.opacity(0.1))
                    .frame(height: 250)
                    .overlay(Image(systemName: "photo").font(.largeTitle))
            }
            
            PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                Label(viewModel.logImage == nil ? "画像を選択" : "画像を変更", systemImage: "photo")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepAromaPage() -> some View {
        @Bindable var viewModel = viewModel
        VStack(spacing: 30) {
            Text("STEP１. 香りを楽しみましょう").font(.headline)
            VStack {
                Text("香りは感じましたか？").padding(5)
                HStack {
                    Text("弱い").padding(5)
                    HStack {
                        ForEach(1...viewModel.maxRating, id: \.self) { number in
                            viewModel.image(for: number, rating: viewModel.aromarating)
                                .font(.system(size: 30))
                                .foregroundColor(number > viewModel.aromarating ? viewModel.offColor : viewModel.onColor)
                                .onTapGesture { viewModel.aromarating = number }
                        }
                    }
                    Text("強い").padding(5)
                }
                Text("どんな香りでしたか？\n(任意)").padding(10)
                TextField("香りの種類", text: $viewModel.aromaComment)
                    .textFieldStyle(.roundedBorder)
                    .padding(10)
            }
            Divider()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepFirstPage() -> some View {
        VStack(spacing: 30) {
            Text("STEP2. １口目の感想を教えてください").font(.headline)
            HStack {
                Text("苦味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bitternessrating1)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bitternessrating1 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bitternessrating1 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("酸味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.acidityrating1)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.acidityrating1 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.acidityrating1 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("コク")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bodyrating1)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bodyrating1 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bodyrating1 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func stepSecondPage() -> some View {
        VStack(spacing: 30) {
            Text("STEP3. 2口目の感想を教えてください").font(.headline)
            HStack {
                Text("苦味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bitternessrating2)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bitternessrating2 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bitternessrating2 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("酸味")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.acidityrating2)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.acidityrating2 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.acidityrating2 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
            
            HStack {
                Text("コク")
                    .padding(5)
                    .font(.system(size:30))
                Text("弱い").padding(5)
                HStack {
                    ForEach(1...viewModel.maxRating, id: \.self) { number in
                        viewModel.image(for: number, rating: viewModel.bodyrating2)
                            .font(.system(size: 20))
                            .foregroundColor(number > viewModel.bodyrating2 ? viewModel.offColor : viewModel.onColor)
                            .onTapGesture { viewModel.bodyrating2 = number }
                    }
                }
                Text("強い").padding(5)
            }
            Spacer()
        }
        .padding()
        
    }
    
    @ViewBuilder
    private func confirmationPage() -> some View {
        VStack(spacing: 20) {
            Text("表示位置を調整してください").font(.headline)
            Text("アイコンをドラッグして、味のポジションを微調整できます。").font(.caption).foregroundColor(.secondary)
            // プレビュー用のカードを表示
            // ここではまだ投稿前なので、現在入力中のデータから一時的な Log を生成して表示します
            if let previewLog = createPreviewLog() {
                PostCardView(log: previewLog, viewModel: viewModel,profileViewModel: profileViewModel,isEditable: true)
                    .frame(height: 400) // プレビューに適したサイズに調整
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
            }
        }
        //---投稿ボタン　※最後のページに貼り付ける ---
        Button {
            viewModel.addLog(currentUser: profileViewModel.user)
            viewModel.aromarating = 0
            dismiss()
        } label: {
            Text("この内容で投稿する")
                .bold()
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.aromarating == 0 ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .disabled(viewModel.aromarating == 0)
        Spacer()
    }
    
    @ViewBuilder
    private func editField(label: String, text: Binding<String>, placeholder: String, isMultiLine: Bool = false) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                // 見出しラベル
                Text(label)
                    .font(.body)
                    .frame(width: 100, alignment: .leading)
                    .padding(.vertical, 12)
                
                // 入力欄
                if isMultiLine {
                    // 複数行の場合
                    TextField(placeholder, text: text, axis: .vertical)
                        .font(.body)
                        .lineLimit(3...6) // 3行〜6行
                        .padding(.vertical, 12)
                } else {
                    // 1行の場合
                    TextField(placeholder, text: text)
                        .font(.body)
                        .lineLimit(1) // 1行固定
                        .padding(.vertical, 12)
                }
            }
            
            Divider()
                .padding(.leading, 0) // 必要に応じてラベルの末尾から線を開始させるなら調整
        }
    }
    
    // 入力中のデータからプレビュー用モデルを作成する補助関数
    private func createPreviewLog() -> Log? {
        return Log(
            user: profileViewModel.user,
            shopName: viewModel.shopName,
            countryName: viewModel.countryName,
            farmName: viewModel.farmName,
            roastLevel: viewModel.roastLevel,
            aromarating: viewModel.aromarating,
            aromaComment: viewModel.aromaComment,
            bitternessrating1: viewModel.bitternessrating1,
            acidityrating1: viewModel.acidityrating1,
            bodyrating1: viewModel.bodyrating1,
            bitternessrating2: viewModel.bitternessrating2,
            acidityrating2: viewModel.acidityrating2,
            bodyrating2: viewModel.bodyrating2,
            createdAt: Date(),
            logImage: viewModel.logImage,
            textOffset: CGSize(width: viewModel.currentOffsetX, height: viewModel.currentOffsetY)
        )
    }
    
    
    //    @ViewBuilder
    //    private func navigationControls() -> some View {
    //        HStack {
    //            if currentStep > 0 {
    //                Button("戻る") {
    //                    withAnimation { currentStep -= 1 }
    //                }
    //            }
    //            Spacer()
    //            if currentStep < totalSteps - 1 {
    //                Button("次へ") {
    //                    withAnimation { currentStep += 1 }
    //                }
    //                .buttonStyle(.borderedProminent)
    //                .disabled(currentStep == 0 && viewModel.countryName.isEmpty)
    //            }
    //        }
    //        .padding()
    //    }
}



struct CountrySelectionView: View {
    @Bindable var viewModel: ViewModel // @Observableの場合
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.regionOrder, id: \.self) { region in
                    Section(header: Text(region)) { // ここは選択不可の見出し
                        ForEach(viewModel.regions[region] ?? [], id: \.self) { country in
                            Button(action: {
                                viewModel.countryName = country
                                dismiss() // 選択したらシートを閉じる
                            }) {
                                HStack {
                                    Text(country)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if viewModel.countryName == country {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("生産国を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct RoastSelectionView: View {
    @Bindable var viewModel: ViewModel // 既存のViewModelを使用
    @Environment(\.dismiss) var dismiss
    
    let roastLevels = [
        "ライトロースト", "シナモンロースト",
        "ミディアムロースト", "ハイロースト",
        "シティロースト", "フルシティロースト",
        "フレンチロースト", "イタリアンロースト"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                // ローストレベルはフラットなリストで作成
                ForEach(roastLevels, id: \.self) { level in
                    Button(action: {
                        viewModel.roastLevel = level // ViewModelの該当プロパティを更新
                        dismiss()
                    }) {
                        HStack {
                            Text(level)
                                .foregroundColor(.primary)
                            Spacer()
                            if viewModel.roastLevel == level {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("焙煎度を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}



#Preview {
    // 1. プレビュー用のインスタンスを作成
    let previewVM = ViewModel()
    let previewProfileVM = ProfileViewModel()
    
    // 2. 環境オブジェクトとして注入してビューを返す
    return ShopLogView()
        .environment(previewVM)
        .environment(previewProfileVM)
}


