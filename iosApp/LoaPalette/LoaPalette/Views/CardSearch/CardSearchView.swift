//
//  CardSearchView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

struct CardSearchView: View {
    @StateObject private var viewModel = CardSearchViewModel()
    @State private var searchText = ""
    @State private var timer: Timer?

    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.searchState == .loading {
                    ProgressView("検索中...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .foregroundColor(.secondary)
                        Button("再試行") {
                            if searchText.isEmpty {
                                viewModel.loadAllCards()
                            } else {
                                viewModel.search(query: searchText)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.cards.isEmpty && viewModel.searchState == .idle {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("カード名を検索してください")
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 8),
                            GridItem(.flexible(), spacing: 8)
                        ], spacing: 16) {
                            ForEach(viewModel.cards) { card in
                                CardItemView(card: card)
                            }
                        }
                        .padding()
                    }
                }
            }
            .searchable(text: $searchText, prompt: "カード名で検索")
            .onChange(of: searchText) { oldValue, newValue in
                timer?.invalidate()
                timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                    viewModel.search(query: newValue)
                }
            }
            .onAppear {
                if viewModel.cards.isEmpty {
                    viewModel.loadAllCards()
                }
            }
            .onDisappear {
                timer?.invalidate()
                viewModel.cleanup()
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
    }
}

struct CardItemView: View {
    let card: LorcanaCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageUrl = card.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(2/3, contentMode: .fit)
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(2/3, contentMode: .fit)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let name = card.name {
                    Text(name)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .lineLimit(2)
                }
                
                HStack {
                    if let cost = card.cost {
                        Label("\(cost)", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if let color = card.color {
                        Text(color)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    CardSearchView()
}

