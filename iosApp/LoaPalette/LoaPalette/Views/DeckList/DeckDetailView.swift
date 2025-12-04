//
//  DeckDetailView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

// デッキ詳細ビュー
struct DeckDetailView: View {
    let deckId: String
    @ObservedObject var viewModel: DeckListViewModel
    let onDismiss: () -> Void

    @State private var isEditMode = false
    @State private var editedDeckName: String = ""
    @State private var editedInkColors: Set<Ink> = []
    @State private var previousInkColors: Set<Ink> = []  // 以前のインクの組み合わせを追跡
    @State private var isDeleteAlertPresented = false
    @State private var displayMode: CardDisplayMode = .list
    @State private var isCardSearchPresented = false
    @State private var editedMemo: String = ""
    @State private var isAddMatchRecordPresented = false
    @State private var isMatchRecordsFullScreenPresented = false  // 試合記録フルスクリーン表示
    @State private var isWinLossSectionExpanded = false  // 勝敗記録セクションの展開状態（デフォルト: 閉じる）
    @State private var isMemoSectionExpanded = true  // メモセクションの展開状態（デフォルト: 開く）

    // カード表示モード
    enum CardDisplayMode: Equatable {
        case list
        case grid
    }

    // ViewModelから最新のデッキ情報を取得（computed propertyに戻す）
    private var deck: Deck? {
        viewModel.decks.first { $0.id == deckId }
    }

    // グリッド表示用のカラム定義
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
    ]

    var body: some View {
        NavigationStack {
            Group {
                if let deck = deck {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 5) {
                            // デッキ情報セクション
                            deckInfoSection(deck: deck)

                            // 勝敗記録セクション
                            WinLossSectionView(
                                deck: deck,
                                viewModel: viewModel,
                                isExpanded: $isWinLossSectionExpanded,
                                isAddMatchRecordPresented: $isAddMatchRecordPresented,
                                isMatchRecordsFullScreenPresented: $isMatchRecordsFullScreenPresented
                            )

                            // メモセクション
                            memoSection(deck: deck)

                            // カードリストセクション
                            cardsSection(deck: deck)
                        }
                        .padding()
                    }
                    .navigationTitle(deck.name)
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text(String(localized: "デッキを読み込み中..."))
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                        Text("deckId: \(deckId)")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .padding(.top, 8)
                        Text(
                            String(
                                format: String(localized: "読み込まれたデッキ数: %lld"), viewModel.decks.count
                            )
                        )
                        .foregroundColor(.secondary)
                        .font(.caption)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle(String(localized: "デッキ詳細"))
                }
            }
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // 表示時にデッキを再読み込み（アプリ起動直後の場合に備える）
                viewModel.loadDecks()
            }
            .onChange(of: isCardSearchPresented) { oldValue, newValue in
                // 検索画面が閉じられた時にデッキを再読み込み
                if oldValue == true && newValue == false {
                    viewModel.loadDecks()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        if isEditMode {
                            saveDeck(deck: deck!)
                            isEditMode = false
                        } else {
                            if let deck = deck {
                                editedDeckName = deck.name
                                editedInkColors = Set(deck.inkColors)
                                previousInkColors = Set(deck.inkColors)
                                editedMemo = deck.memo
                            }
                            isEditMode = true
                        }
                    } label: {
                        Text(isEditMode ? String(localized: "完了") : String(localized: "編集"))
                    }

                    Menu {
                        Button(role: .destructive) {
                            isDeleteAlertPresented = true
                        } label: {
                            Label(String(localized: "削除"), systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .alert(String(localized: "デッキを削除"), isPresented: $isDeleteAlertPresented) {
                Button(String(localized: "キャンセル"), role: .cancel) {}
                Button(String(localized: "削除"), role: .destructive) {
                    deleteDeck()
                }
            } message: {
                Text(String(localized: "このデッキを削除してもよろしいですか？"))
            }
            .fullScreenCover(isPresented: $isCardSearchPresented) {
                if let deck = deck {
                    // デッキのインク色をCardSearchFilterAccessoryView.Filterに変換
                    let inkFilters = deck.inkColors.compactMap { ink in
                        CardSearchFilterAccessoryView.Filter(rawValue: ink.rawValue)
                    }
                    CardSearchView(
                        isPresentedAsSheet: true,
                        targetDeckId: deck.id,
                        initialInkFilters: inkFilters
                    )
                } else {
                    CardSearchView(isPresentedAsSheet: true)
                }
            }
            .sheet(isPresented: $isAddMatchRecordPresented) {
                if let deck = deck {
                    AddMatchRecordView(
                        deckId: deck.id,
                        viewModel: viewModel,
                        onDismiss: {
                            isAddMatchRecordPresented = false
                        }
                    )
                }
            }
            .fullScreenCover(isPresented: $isMatchRecordsFullScreenPresented) {
                if let deck = deck {
                    MatchRecordsFullScreenView(
                        deckId: deck.id,
                        viewModel: viewModel,
                        onDismiss: {
                            isMatchRecordsFullScreenPresented = false
                        }
                    )
                }
            }
        }
    }

    private func deckInfoSection(deck: Deck) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if isEditMode {
                // デッキ名編集
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "デッキ名"))
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    TextField(String(localized: "未入力の場合はインク名になります"), text: $editedDeckName)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: editedInkColors) { oldValue, newValue in
                            // インク色が変更されたら、名前が空または自動生成された名前の場合は更新
                            let trimmedName = editedDeckName.trimmingCharacters(
                                in: .whitespacesAndNewlines)
                            if trimmedName.isEmpty
                                || isAutoGeneratedName(trimmedName, previousColors: oldValue)
                            {
                                updateDeckNameFromInkColors()
                                previousInkColors = newValue
                            } else {
                                previousInkColors = newValue
                            }
                        }
                }

                // インク色選択
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "インク（最大2色）"))
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Ink.allCases) { inkColor in
                            inkColorChip(inkColor: inkColor)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top, 2)
                }
            } else {
                // インク色表示
                if !deck.inkColors.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(deck.inkColors, id: \.self) { ink in
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(ink.color)
                                    .frame(width: 8, height: 8)
                                Text(ink.japaneseName)
                                    .font(.caption)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.top, 4)
                }
            }

            HStack(spacing: 20) {
                InfoItem(
                    icon: "rectangle.stack",
                    value: String(format: String(localized: "%lld枚"), deck.totalCardCount))
                InfoItem(icon: "clock", value: formatDate(deck.updatedAt))
            }

            // 60枚以下の場合、検索画面への動線を表示
            if deck.totalCardCount < 60 {
                Button {
                    isCardSearchPresented = true
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text(
                            String(
                                format: String(localized: "カードを追加（あと%lld枚）"),
                                60 - deck.totalCardCount)
                        )
                        .font(.subheadline)
                        .fontWeight(.medium)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .foregroundColor(.accentColor)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }

    private func cardsSection(deck: Deck) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // タイトルと切り替えボタンを同列に配置
            HStack {
                Text(String(localized: "カード一覧"))
                    .font(.headline)

                Spacer()

                // 表示モード切り替えボタン
                Picker(String(localized: "表示モード"), selection: $displayMode) {
                    Image(systemName: "list.bullet")
                        .tag(CardDisplayMode.list)
                    Image(systemName: "square.grid.2x2")
                        .tag(CardDisplayMode.grid)
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }

            if deck.entries.isEmpty {
                emptyCardsView
            } else {
                if displayMode == .list {
                    cardsList(deck: deck)
                } else {
                    cardsGrid(deck: deck)
                }
            }
        }
    }

    private var emptyCardsView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(String(localized: "カードがありません"))
                .foregroundColor(.secondary)
            Text(String(localized: "検索画面からカードを追加してください"))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func cardsList(deck: Deck) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(deck.entries) { entry in
                CardEntryRow(entry: entry) { newCount in
                    updateCardCount(deckId: deck.id, cardId: entry.id, count: newCount)
                } onDelete: {
                    removeCard(deckId: deck.id, cardId: entry.id)
                }
            }
        }
    }

    private func cardsGrid(deck: Deck) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(deck.entries) { entry in
                    CardGridItemView(entry: entry) { newCount in
                        updateCardCount(deckId: deck.id, cardId: entry.id, count: newCount)
                    } onDelete: {
                        removeCard(deckId: deck.id, cardId: entry.id)
                    }
                }
            }
            .padding()
        }
    }

    private func saveDeck(deck: Deck) {
        let trimmedName = editedDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
        let inkColors = Array(editedInkColors).sorted { $0.rawValue < $1.rawValue }

        var updatedDeck = deck
        updatedDeck.name = trimmedName
        updatedDeck.inkColors = inkColors
        updatedDeck.memo = editedMemo

        // 名前が空でインク色が選択されている場合は、インク色からデッキ名を生成
        if updatedDeck.name.isEmpty && !updatedDeck.inkColors.isEmpty {
            updatedDeck.name = Ink.generateDeckName(colors: updatedDeck.inkColors)
        }

        viewModel.updateDeck(updatedDeck)
    }

    // インク色チップ（詳細検索と同じスタイル）
    private func inkColorChip(inkColor: Ink) -> some View {
        let isSelected = editedInkColors.contains(inkColor)
        let canSelect = editedInkColors.count < 2 || isSelected

        return Button {
            let oldColors = editedInkColors
            if isSelected {
                editedInkColors.remove(inkColor)
                // 名前が空または自動生成された名前の場合は更新
                let trimmedName = editedDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedName.isEmpty
                    || isAutoGeneratedName(trimmedName, previousColors: oldColors)
                {
                    updateDeckNameFromInkColors()
                    previousInkColors = editedInkColors
                } else {
                    previousInkColors = editedInkColors
                }
            } else if canSelect {
                editedInkColors.insert(inkColor)
                // 名前が空または自動生成された名前の場合は更新
                let trimmedName = editedDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedName.isEmpty
                    || isAutoGeneratedName(trimmedName, previousColors: oldColors)
                {
                    updateDeckNameFromInkColors()
                    previousInkColors = editedInkColors
                } else {
                    previousInkColors = editedInkColors
                }
            }
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(inkColor.color)
                    .frame(width: 8, height: 8)

                Text(inkColor.japaneseName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 999)
                    .fill(isSelected ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 999)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .opacity(canSelect ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // 現在の名前が以前のインク色の組み合わせから自動生成された名前かどうかをチェック
    private func isAutoGeneratedName(_ name: String, previousColors: Set<Ink>) -> Bool {
        let colors = Array(previousColors).sorted { $0.rawValue < $1.rawValue }
        let autoGeneratedName = Ink.generateDeckName(colors: colors)
        // 空の場合は自動生成された名前とみなす
        if autoGeneratedName.isEmpty {
            return name.isEmpty
        }
        return name == autoGeneratedName
    }

    // インク色からデッキ名を更新
    private func updateDeckNameFromInkColors() {
        let colors = Array(editedInkColors).sorted { $0.rawValue < $1.rawValue }
        editedDeckName = Ink.generateDeckName(colors: colors)
    }

    private func updateCardCount(deckId: String, cardId: String, count: Int) {
        viewModel.updateCardCountInDeck(deckId, cardId: cardId, count: count)
    }

    private func removeCard(deckId: String, cardId: String) {
        viewModel.removeCardFromDeck(deckId, cardId: cardId)
    }

    private func deleteDeck() {
        guard let deck = deck else { return }
        viewModel.deleteDeck(deck.id)
        onDismiss()
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }


    // メモセクション
    private func memoSection(deck: Deck) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation {
                    isMemoSectionExpanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: isMemoSectionExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(localized: "メモ"))
                        .font(.headline)
                }
            }
            .buttonStyle(.plain)
            
            if isMemoSectionExpanded {
                if isEditMode {
                    TextEditor(text: $editedMemo)
                        .frame(minHeight: 100)
                        .padding(8)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                } else {
                    if deck.memo.isEmpty {
                        Text(String(localized: "メモがありません"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    } else {
                        Text(deck.memo)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
}


// 情報アイテムビュー
struct InfoItem: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
            Text(value)
                .font(.caption)
        }
        .foregroundColor(.secondary)
    }
}

// カードエントリ行ビュー
struct CardEntryRow: View {
    let entry: DeckEntry
    let onCountChange: (Int) -> Void
    let onDelete: () -> Void

    @State private var count: Int

    init(entry: DeckEntry, onCountChange: @escaping (Int) -> Void, onDelete: @escaping () -> Void) {
        self.entry = entry
        self.onCountChange = onCountChange
        self.onDelete = onDelete
        _count = State(initialValue: entry.count)
    }

    var body: some View {
        HStack(spacing: 12) {
            // カード画像
            if let imageUrl = entry.card.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .aspectRatio(2 / 3, contentMode: .fit)
                }
                .frame(width: 50, height: 75)
                .cornerRadius(4)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 50, height: 75)
                    .cornerRadius(4)
            }

            // カード情報
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.card.name ?? String(localized: "不明なカード"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(2)

                HStack(spacing: 8) {
                    if let cost = entry.card.cost {
                        Label("\(cost)", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if let color = entry.card.color {
                        Text(color)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Spacer()

            // 枚数コントロール
            HStack(spacing: 8) {
                Button {
                    if count > 1 {
                        count -= 1
                        onCountChange(count)
                    } else {
                        onDelete()
                    }
                } label: {
                    Image(systemName: count > 1 ? "minus.circle" : "trash")
                        .foregroundColor(count > 1 ? .blue : .red)
                }

                Text("\(count)")
                    .font(.headline)
                    .frame(minWidth: 30)

                if count < 4 {
                    Button {
                        count += 1
                        onCountChange(count)
                    } label: {
                        Image(systemName: "plus.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// グリッド表示用のカードエントリビュー
struct CardGridItemView: View {
    let entry: DeckEntry
    let onCountChange: (Int) -> Void
    let onDelete: () -> Void

    @State private var count: Int

    init(entry: DeckEntry, onCountChange: @escaping (Int) -> Void, onDelete: @escaping () -> Void) {
        self.entry = entry
        self.onCountChange = onCountChange
        self.onDelete = onDelete
        _count = State(initialValue: entry.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                // カード画像を枚数分重ねて表示
                ForEach(0..<count, id: \.self) { index in
                    let offset: CGFloat = CGFloat(index) * 8.0
                    if let imageUrl = entry.card.imageUrl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .aspectRatio(2 / 3, contentMode: .fit)
                        }
                        .offset(x: offset, y: offset)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                        .zIndex(Double(count - index))
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .aspectRatio(2 / 3, contentMode: .fit)
                            .offset(x: offset, y: offset)
                            .shadow(color: Color.black.opacity(0.2), radius: 4, x: 2, y: 2)
                            .zIndex(Double(count - index))
                    }
                }

                // 枚数バッジ（右上に配置）
                VStack {
                    HStack {
                        Spacer()
                        Text("×\(count)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(8)
                            .padding(4)
                    }
                    Spacer()
                }
                .zIndex(Double(count + 1))
            }
            .frame(minHeight: 200)
            .padding(.bottom, CGFloat(count - 1) * 8.0)
            .padding(.trailing, CGFloat(count - 1) * 8.0)

            // カード情報
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.card.name ?? String(localized: "不明なカード"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(2)

                HStack {
                    if let cost = entry.card.cost {
                        Label("\(cost)", systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if let color = entry.card.color {
                        Text(color)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 4)

            // 枚数コントロール
            HStack(spacing: 4) {
                Button {
                    if count > 1 {
                        count -= 1
                        onCountChange(count)
                    } else {
                        onDelete()
                    }
                } label: {
                    Image(systemName: count > 1 ? "minus.circle.fill" : "trash.fill")
                        .font(.caption)
                        .foregroundColor(count > 1 ? .blue : .red)
                }

                Spacer()

                if count < 4 {
                    Button {
                        count += 1
                        onCountChange(count)
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
