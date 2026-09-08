//
//  News.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI
import FirebaseFirestore

struct News: Identifiable, Codable {
    @DocumentID var id: String?
    var storeId: String
    var title: String
    var subtitle: String
    var date: String
    var bodyText: String
    var linkUrl: String
    var imageUrl: String
}
