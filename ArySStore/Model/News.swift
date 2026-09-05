//
//  News.swift
//  ArySStore
//
//  Created by katoso on 2026/09/03.
//

import SwiftUI

struct News: Identifiable {
    let id = UUID()
    var title: String
    var subtitle: String
    var date: String
    var bodyText: String
    var linkUrl: String
}
