//
//  CardSearchView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

struct CardSearchView: View {
    @StateObject private var viewModel = CardSearchViewModel()
    @StateObject private var deckListViewModel = DeckListViewModel()
    @State private var searchText = ""
    @State private var timer: Timer?
    @State private var isFilterSheetPresented = false
    @State private var selectedCards: Set<String> = []
    @State private var isDeckSelectionPresented = false
    @Environment(\.dismiss) private var dismiss

    // シート表示かどうか（デッキ詳細から遷移した場合など）
    var isPresentedAsSheet: Bool = false

    // 追加先のデッキID（デッキ詳細から遷移した場合に設定）
    var targetDeckId: String? = nil

    // 初期インクフィルター（デッキ詳細から遷移した場合に設定）
    var initialInkFilters: [CardSearchFilterAccessoryView.Filter] = []

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
                .searchable(text: $searchText, prompt: String(localized: "カード名を入力して検索"))
                .toolbar {
                    if isPresentedAsSheet {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                            }
                        }
                    }
                }
                .onChange(of: searchText) { oldValue, newValue in
                    timer?.invalidate()
                    timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        if trimmed.isEmpty {
                            // 検索テキストが空の場合、インクフィルターがあればそれで検索
                            if !selectedFilters.isEmpty {
                                let colorClauses = Array(selectedFilters).map { $0.searchClause }
                                let searchQuery =
                                    colorClauses.count == 1
                                    ? colorClauses[0]
                                    : "(\(colorClauses.joined(separator: ";|"));)"
                                viewModel.search(query: searchQuery)
                            } else {
                                viewModel.search(query: "")
                            }
                        } else {
                            // 検索テキストがある場合、インクフィルターと組み合わせる
                            var clauses: [String] = ["name~\(trimmed)"]
                            if !selectedFilters.isEmpty {
                                let colorClauses = Array(selectedFilters).map { $0.searchClause }
                                if colorClauses.count == 1 {
                                    clauses.append(colorClauses[0])
                                } else if colorClauses.count > 1 {
                                    clauses.append("(\(colorClauses.joined(separator: ";|"));)")
                                }
                            }
                            viewModel.search(query: clauses.joined(separator: ";"))
                        }
                    }
                }
                .onAppear {
                    // デッキ詳細から遷移した場合、インクで自動的に絞り込む
                    if !initialInkFilters.isEmpty {
                        selectedFilters = Set(initialInkFilters)

                        // インクで検索を実行
                        let colorClauses = initialInkFilters.map { $0.searchClause }
                        let searchQuery =
                            colorClauses.count == 1
                            ? colorClauses[0]
                            : "(\(colorClauses.joined(separator: ";|"));)"
                        viewModel.search(query: searchQuery)
                    } else if viewModel.cards.isEmpty {
                        // インクフィルターがない場合のみ、全カードを読み込む
                        viewModel.loadAllCards()
                    }
                }
                .onDisappear {
                    timer?.invalidate()
                    viewModel.cleanup()
                }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                if !selectedCards.isEmpty {
                    HStack(spacing: 12) {
                        Button {
                            selectedCards.removeAll()
                        } label: {
                            Text(String(localized: "選択解除"))
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Text(String(format: String(localized: "%lld枚選択中"), selectedCards.count))
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Button {
                            if let targetDeckId = targetDeckId {
                                // デッキ詳細から遷移した場合、直接そのデッキに追加
                                addCardsToTargetDeck(deckId: targetDeckId)
                            } else {
                                // 通常の場合はデッキ選択画面を表示
                                isDeckSelectionPresented = true
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "plus.circle.fill")
                                Text(String(localized: "デッキに追加"))
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.accentColor)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                }

                Button {
                    isFilterSheetPresented = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                        Text(String(localized: "詳細検索"))
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
        .sheet(isPresented: $isDeckSelectionPresented) {
            DeckSelectionView(
                selectedCardIds: selectedCards,
                cards: viewModel.cards,
                deckListViewModel: deckListViewModel,
                onComplete: {
                    selectedCards.removeAll()
                    isDeckSelectionPresented = false
                }
            )
        }
    }

    // デッキ詳細から遷移した場合、直接そのデッキにカードを追加
    private func addCardsToTargetDeck(deckId: String) {
        let selectedCardsArray = filteredCards.filter { selectedCards.contains($0.id) }
        for card in selectedCardsArray {
            deckListViewModel.addCardToDeck(deckId, card: card, count: 1)
        }
        selectedCards.removeAll()

        // ハプティックフィードバック
        #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        #endif
    }
    // フィルタリングされたカードリスト（2色設定時、その2色以外を含むカードを除外）
    private var filteredCards: [LorcanaCard] {
        // 2色設定されている場合のみフィルタリング
        let activeFilters = !initialInkFilters.isEmpty ? initialInkFilters : Array(selectedFilters)
        guard activeFilters.count == 2 else {
            return viewModel.cards
        }

        let allowedColors = Set(activeFilters.map { $0.rawValue })

        return viewModel.cards.filter { card in
            guard let colorString = card.color else { return false }
            // カンマ区切りの色文字列を解析
            let cardColors = colorString.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespaces)
            }
            // カードのすべての色が、選択された2色のいずれかである必要がある
            return Set(cardColors).isSubset(of: allowedColors)
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
            case .idle where filteredCards.isEmpty:
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
            Button(String(localized: "再試行")) {
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
            Text(String(localized: "カード名を入力して検索"))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // 検索結果グリッド.
    private var cardsGrid: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(filteredCards) { card in
                    CardItemView(
                        card: card,
                        isSelected: selectedCards.contains(card.id),
                        onTap: {
                            if selectedCards.contains(card.id) {
                                selectedCards.remove(card.id)
                            } else {
                                selectedCards.insert(card.id)
                            }
                        }
                    )
                }
            }
            .padding()
        }
    }
}

struct CardItemView: View {
    let card: LorcanaCard
    var isSelected: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
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

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .background(Color.white.clipShape(Circle()))
                        .padding(4)
                }
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
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap?()
        }
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
