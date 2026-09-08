//
//  StoreNewsListViewModel.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI
import Observation
import FirebaseAuth
import FirebaseFirestore

@Observable
@MainActor
class StoreNewsListViewModel {
    var newsList: [News] = []
    var newsImages: [String: UIImage] = [:]
    private var cachedImageUrls: [String: String] = [:]
    
    @ObservationIgnored
    private var listener: ListenerRegistration?
    
    init() {
        fetchNews()
    }
    
    deinit {
        listener?.remove()
    }
    
    func fetchNews() {
        guard let storeUid = Auth.auth().currentUser?.uid else { return }
        
        listener = Firestore.firestore().collection("news")
            .whereField("storeId", isEqualTo: storeUid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self, let documents = snapshot?.documents else { return }
                
                let loadedNews: [News] = documents.compactMap { doc -> News? in
                    let data = doc.data()
                    let id = doc.documentID
                    let storeId = data["storeId"] as? String ?? storeUid
                    let title = data["title"] as? String ?? ""
                    let subtitle = data["subtitle"] as? String ?? ""
                    let bodyText = data["bodyText"] as? String ?? ""
                    let linkUrl = data["linkUrl"] as? String ?? ""
                    let imageUrl = data["imageUrl"] as? String ?? ""
                    
                    var dateString = ""
                    if let timestamp = data["createdAt"] as? Timestamp {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy/MM/dd HH:mm"
                        dateString = formatter.string(from: timestamp.dateValue())
                    }
                    
                    return News(
                        id: id,
                        storeId: storeId,
                        title: title,
                        subtitle: subtitle,
                        date: dateString,
                        bodyText: bodyText,
                        linkUrl: linkUrl,
                        imageUrl: imageUrl
                    )
                }
                
                Task { @MainActor in
                    self.newsList = loadedNews
                    for news in loadedNews {
                        if !news.imageUrl.isEmpty, let url = URL(string: news.imageUrl) {
                            await self.fetchImage(for: news.id ?? "", from: url, urlString: news.imageUrl)
                        }
                    }
                }
            }
    }
    
    private func fetchImage(for id: String, from url: URL, urlString: String) async {
        if newsImages[id] != nil, cachedImageUrls[id] == urlString {
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                newsImages[id] = image
                cachedImageUrls[id] = urlString
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }
    
    func deleteNews(at indexSet: IndexSet) {
        for index in indexSet {
            let news = newsList[index]
            if let id = news.id {
                Firestore.firestore().collection("news").document(id).delete()
                newsImages.removeValue(forKey: id)
                cachedImageUrls.removeValue(forKey: id)
            }
        }
    }
}
