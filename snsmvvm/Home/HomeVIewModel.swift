//
//  HomeVIewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/04.
//


import SwiftUI

@Observable

class HomeViewModel {
    var logs: [Log] = []
    var selectedTab: Int = 0
}
