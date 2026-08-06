//
//  CoffeeLogView.swift
//  snsmvvm
//
//  Created by katoso on 2026/06/01.
//

import SwiftUI
import PhotosUI
import FirebaseAuth


struct CoffeeLogView: View {
    let log: Log
    let author: User?
    let authorName: String
    @State var coffeeLogViewModel: CoffeeLogViewModel
    @Environment(ProfileViewModel.self) var profileViewModel
    var isEditable: Bool
    var onDelete: () -> Void
    var onEdit: () -> Void
    
    @State private var isShowingDetailSheet = false
    
    private var isMyPost: Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        return log.userId == currentUid
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Group {
                    if let previewImage = log.previewImage {
                        Image(uiImage: previewImage)
                            .resizable()
                            .scaledToFill()
                    } else if let urlString = log.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                        placeholder: { ProgressView() }
                    }
                }
                .aspectRatio(4/3, contentMode: .fit)
                .clipped()
                
                HStack(spacing: 12) {
                    let displayUser = isMyPost ? profileViewModel.user : author
                    if let urlString = displayUser?.profileImageUrl, !urlString.isEmpty, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                        placeholder: { Circle().fill(Color.gray) }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill").resizable().frame(width: 40, height: 40).foregroundColor(.gray)
                    }
                    Text(authorName).font(.title2).bold()
                    Spacer()
                    Text(log.createdAt, style: .date).font(.caption).foregroundColor(.secondary)
                    if isMyPost {
                        Menu {
                            Button { onEdit()
                            } label: {
                                Label("編集", systemImage: "pencil")
                            }
                            Button(role: .destructive) { onDelete()
                            } label: {
                                Label("削除", systemImage: "trash")
                            }
                        } label: { Image(systemName: "ellipsis").padding(5).foregroundColor(.primary) }
                    } else {
                        Menu {
                            Button (role: .destructive){
                            } label: {
                                Label("報告する", systemImage: "exclamationmark.bubble")
                            }
                        } label: { Image(systemName: "ellipsis").padding(5).foregroundColor(.primary) }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                .padding(16)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Shop: \(log.shopName)")
                    Text("Origin: \(log.countryName)")
                    Text("Farm: \(log.farmName)")
                    Text("Roast: \(log.roastLevel)")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                .padding(16)
                .onTapGesture { if !isEditable { isShowingDetailSheet = true } }
                
                
                VStack (spacing: 10){
                    Button {
                        coffeeLogViewModel.isLiked.toggle()
                    } label: {
                        Image (systemName: coffeeLogViewModel.isLiked ? "heart.fill" : "heart")
                            .foregroundColor(coffeeLogViewModel.isLiked ? .red : .white)
                            .font(.system(size:30))
                    }
                    Button {
                        coffeeLogViewModel.isSaved.toggle()
                    } label: {
                        Image (systemName: coffeeLogViewModel.isSaved ? "bookmark.fill" : "bookmark")
                            .foregroundColor(.white)
                            .font(.system(size:30))
                    }
                    Button {
                    } label: {Image (systemName: "arrowshape.turn.up.right.fill")
                            .font(.system(size:30))
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.6), radius: 2, x: 0, y: 1)
                .padding(16)
            }
        }
        .sheet(isPresented: $isShowingDetailSheet) {
            detailSheetView
        }
    }
    
    // --- 詳細シート用ビュー ---
    private var detailSheetView: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    if let urlString = log.imageUrl, let url = URL(string: urlString) {
                        AsyncImage(url: url) { image in image.resizable().scaledToFill() }
                        placeholder: { ProgressView() }
                            .aspectRatio(4/3, contentMode: .fit)
                            .clipped()
                    }
                    
                    // --- 2. 下部：詳細エリア ---
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Coffee Review")
                            .font(.title2).bold()
                            .padding(.top, 20)
                        
                        VStack(alignment: .leading, spacing: 18) {
                            // --- Bitterness ---
                            VStack(alignment: .leading, spacing: 6) {
                                let rating = Double(log.bitternessrating)
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("Bitterness").font(.subheadline).bold()
                                    Text(String(format: "%.1f", rating)).font(.subheadline).bold().foregroundColor(.orange)
                                }
                                RatingView(rating: rating, maxRating: 5)
                            }
                            
                            // --- Acidity ---
                            VStack(alignment: .leading, spacing: 6) {
                                let rating = Double(log.acidityrating)
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("Acidity").font(.subheadline).bold()
                                    Text(String(format: "%.1f", rating)).font(.subheadline).bold().foregroundColor(.orange)
                                }
                                RatingView(rating: rating, maxRating: 5)
                            }
                            
                            // --- Body ---
                            VStack(alignment: .leading, spacing: 6) {
                                let rating = Double(log.bodyrating)
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("Body").font(.subheadline).bold()
                                    Text(String(format: "%.1f", rating)).font(.subheadline).bold().foregroundColor(.orange)
                                }
                                RatingView(rating: rating, maxRating: 5)
                            }
                            
                            // --- Aroma ---
                            VStack(alignment: .leading, spacing: 6) {
                                let rating = Double(log.aromarating)
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text("Aroma").font(.subheadline).bold()
                                    Text(String(format: "%.1f", rating)).font(.subheadline).bold().foregroundColor(.orange)
                                }
                                RatingView(rating: rating, maxRating: 5)
                            }
                            
                            // --- 香りのコメント ---
                            if !log.aromaComment.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("香りの種類:")
                                        .font(.subheadline)
                                        .bold()
                                        .foregroundColor(.secondary)
                                    Text(log.aromaComment)
                                        .font(.body)
                                }
                                .padding(.top, 8)
                            }
                        }
                    }
                    .padding(24)
                }
            }
            .presentationDetents([.fraction(1.0)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
    }
}
