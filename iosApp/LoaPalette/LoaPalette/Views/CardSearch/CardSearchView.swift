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
    @State private var isFilterSheetPresented = false

    // フィルター状態を保持.
    @State private var selectedFilters: Set<CardSearchFilterAccessoryView.Filter> = []
    @State private var filterNameQuery: String = ""
    @State private var filterMinCost: Int = 0
    @State private var filterMaxCost: Int = 10
    @State private var selectedTypes: Set<CardSearchFilterAccessoryView.CardType> = []
    @State private var selectedRarities: Set<CardSearchFilterAccessoryView.Rarity> = []
    @State private var inkableFilter: CardSearchFilterAccessoryView.InkableFilter = .any
    @State private var filterMinStrength: Int = 0
    @State private var filterMaxStrength: Int = 20
    @State private var filterMinWillpower: Int = 0
    @State private var filterMaxWillpower: Int = 20
    @State private var filterMinLore: Int = 0
    @State private var filterMaxLore: Int = 5
    @State private var filterSetName: String = ""
    @State private var filterArtist: String = ""

    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]

    var body: some View {
        NavigationStack {
            content
                .searchable(text: $searchText, prompt: "カード名で検索")
                .onChange(of: searchText) { oldValue, newValue in
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty {
                            viewModel.search(query: "")
                        } else {
                            // ユーザー入力は name~text としてLorcana APIに渡す.
                            viewModel.search(query: "name~\(trimmed)")
                        }
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
        .safeAreaInset(edge: .bottom) {
            Button {
                isFilterSheetPresented = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                    Text("詳細に検索")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial.opacity(0.6))
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.bottom, 8)
        }
        .sheet(isPresented: $isFilterSheetPresented) {
            CardSearchFilterAccessoryView(
                selectedFilters: $selectedFilters,
                nameQuery: $filterNameQuery,
                minCost: $filterMinCost,
                maxCost: $filterMaxCost,
                selectedTypes: $selectedTypes,
                selectedRarities: $selectedRarities,
                inkableFilter: $inkableFilter,
                minStrength: $filterMinStrength,
                maxStrength: $filterMaxStrength,
                minWillpower: $filterMinWillpower,
                maxWillpower: $filterMaxWillpower,
                minLore: $filterMinLore,
                maxLore: $filterMaxLore,
                setName: $filterSetName,
                artist: $filterArtist,
                onSelect: { searchClause in
                    // 詳細検索時は検索バーのテキストは変更せず、searchパラメータだけ更新.
                    viewModel.search(query: searchClause)
                    isFilterSheetPresented = false
                }
            )
            .modifier(FilterSheetDetentsModifier())
        }
    }
    // 状態ごとのコンテンツ切り出し.
    @ViewBuilder
    private var content: some View {
        VStack {
            switch viewModel.searchState {
            case .loading:
                loadingPlaceholderGrid
            case .error:
                if let errorMessage = viewModel.errorMessage {
                    errorView(message: errorMessage)
                } else {
                    loadingPlaceholderGrid
                }
            case .idle where viewModel.cards.isEmpty:
                emptyStateView
            default:
                cardsGrid
            }
        }
    }

    // ローディング中のプレースホルダーグリッド.
    private var loadingPlaceholderGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(0..<8) { _ in
                    CardPlaceholderView()
                        .shimmer()
                }
            }
            .padding()
        }
    }

    // エラー表示ビュー.
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)
            Text(message)
                .foregroundColor(.secondary)
            Button("再試行") {
                if searchText.isEmpty {
                    viewModel.loadAllCards()
                } else {
                    let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmed.isEmpty {
                        viewModel.loadAllCards()
                    } else {
                        viewModel.search(query: "name~\(trimmed)")
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // 検索前の空状態ビュー.
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("カード名を検索してください")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // 検索結果グリッド.
    private var cardsGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(viewModel.cards) { card in
                    CardItemView(card: card)
                }
            }
            .padding()
        }
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
                        .aspectRatio(2 / 3, contentMode: .fit)
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(2 / 3, contentMode: .fit)
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

// プレースホルダー用カードビュー（ローディング時に表示）.
private struct CardPlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .aspectRatio(2 / 3, contentMode: .fit)
                .cornerRadius(6)

            VStack(alignment: .leading, spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 10)

                HStack {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 40, height: 8)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.gray.opacity(0.25))
                        .frame(width: 40, height: 8)
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// シマーアニメーション用モディファイア.
private struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.0),
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.0),
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .scaleEffect(3)
                .offset(x: phase * 200, y: phase * 200)
                .blendMode(.plusLighter)
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.2)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 1.5
                }
            }
    }
}

extension View {
    // シマーアニメーションを適用.
    fileprivate func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
}

#Preview {
    CardSearchView()
}
