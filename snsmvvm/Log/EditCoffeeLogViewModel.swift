//
//  EditCoffeeLogViewModel.swift
//  snsmvvm
//
//  Created by katoso on 2026/07/04.
//

import SwiftUI

@Observable

class EditCoffeeLogViewModel {
    var logs: [Log] = []
    var editingUser: String = ""
    var editingCoffee: String = ""
    var editingFavoCoffee: String = ""
    var editingContent: String = ""
    var editingRating: Int = 0
    var isEditSheet: Bool = false
    
    var maxRating = 5
    var offImage: Image?
    var onImage = Image(systemName: "star.fill")
    var offColor = Color.gray
    var onColor = Color.yellow
    
    func updateLog(targetPost: Log) {
        if let id = logs.firstIndex(where: { $0.id == targetPost.id }) {
            logs[id].countryName = self.editingCoffee
            logs[id].aromarating = self.editingRating
            clearEditingLog()
            self.isEditSheet = false
        }
    }
    
    func clearEditingLog() {
        self.editingCoffee = ""
        self.editingContent = ""
        self.editingRating = 0
    }
    
    func image(for number: Int, rating: Int) -> Image {
        if number > rating {
            return offImage ?? Image(systemName: "star")
        } else {
            return onImage
        }
    }
}
