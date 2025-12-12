
import SwiftUI

struct DeckListView: View {
    @StateObject private var viewModel = DeckListViewModel()
    @State private var selectedDeck: Deck? = nil
    @State private var isNewDeckSheetPresented = false
    @State private var newDeckName: String = ""
    @State private var selectedInkColors: Set<Ink> = []
    @State private var previousInkColors: Set<Ink> = []  // 以前のインクの組み合わせを追跡

    var body: some View {
        NavigationStack {
            ZStack {
                content
                    .navigationTitle(String(localized: "デッキリスト"))
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isNewDeckSheetPresented = true
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(item: $selectedDeck) { deck in
                        DeckDetailView(
                            deck: deck,
                            viewModel: viewModel,
                            onDismiss: {
                                selectedDeck = nil
                            }
                        )
                    }
                    .sheet(isPresented: $isNewDeckSheetPresented) {
                        newDeckSheet
                    }

                // ロード中または保存中のプログレス表示
                if viewModel.isLoading || viewModel.isSaving {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .overlay {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)
                                    .tint(.white)
                                Text(viewModel.isLoading ? String(localized: "読み込み中...") : String(localized: "保存中..."))
                                    .foregroundColor(.white)
                                    .font(.subheadline)
                            }
                            .padding(24)
                            .background(.ultraThinMaterial)
                            .cornerRadius(16)
                        }
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.decks.isEmpty {
            emptyStateView
        } else {
            deckList
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text(String(localized: "デッキがありません"))
                .font(.headline)
                .foregroundColor(.secondary)
            Text(String(localized: "右上の+ボタンから新しいデッキを作成してください"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var deckList: some View {
        List {
            ForEach(viewModel.decks) { deck in
                DeckRowView(deck: deck)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        print("DeckListView - deck tapped: \(deck.id), name: \(deck.name)")
                        AnalyticsManager.shared.logDeckSelect(deckName: deck.name)
                        selectedDeck = deck
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            viewModel.deleteDeck(deck.id)
                        } label: {
                            Label(String(localized: "削除"), systemImage: "trash")
                        }
                    }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.refreshDecks()
        }
    }

    private var newDeckSheet: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // デッキ名セクション（詳細検索と同じレイアウト）
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "デッキ名"))
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        TextField(String(localized: "デッキ名"), text: $newDeckName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.trailing, 4)
                            .onChange(of: selectedInkColors) { oldValue, newValue in
                                // インクが変更されたら、名前が空または自動生成された名前の場合は更新
                                let trimmedName = newDeckName.trimmingCharacters(
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
                    .padding(.horizontal, 16)

                    // インク選択セクション（詳細検索と同じレイアウト）
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
                    .padding(.horizontal, 16)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(String(localized: "新しいデッキ"))
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // シートが開かれたときに以前のインクをリセット
                previousInkColors = selectedInkColors
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "キャンセル")) {
                        isNewDeckSheetPresented = false
                        newDeckName = ""
                        selectedInkColors.removeAll()
                        previousInkColors.removeAll()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "作成")) {
                        createNewDeck()
                    }
                    .disabled(
                        selectedInkColors.isEmpty
                            && newDeckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    // インクチップ（詳細検索と同じスタイル）
    private func inkColorChip(inkColor: Ink) -> some View {
        let isSelected = selectedInkColors.contains(inkColor)
        let canSelect = selectedInkColors.count < 2 || isSelected

        return Button {
            let oldColors = selectedInkColors
            if isSelected {
                selectedInkColors.remove(inkColor)
                // 名前が空または自動生成された名前の場合は更新
                let trimmedName = newDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedName.isEmpty
                    || isAutoGeneratedName(trimmedName, previousColors: oldColors)
                {
                    updateDeckNameFromInkColors()
                    previousInkColors = selectedInkColors
                } else {
                    previousInkColors = selectedInkColors
                }
            } else if canSelect {
                selectedInkColors.insert(inkColor)
                // 名前が空または自動生成された名前の場合は更新
                let trimmedName = newDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmedName.isEmpty
                    || isAutoGeneratedName(trimmedName, previousColors: oldColors)
                {
                    updateDeckNameFromInkColors()
                    previousInkColors = selectedInkColors
                } else {
                    previousInkColors = selectedInkColors
                }
            }
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(inkColor.color)
                    .frame(width: 8, height: 8)

                Text(inkColor.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 999)
                    .fill(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 999)
                    .stroke(Color.white.opacity(isSelected ? 0.6 : 0.2), lineWidth: 1)
            )
            .opacity(canSelect ? 1.0 : 0.5)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // 現在の名前が以前のインクの組み合わせから自動生成された名前かどうかをチェック
    private func isAutoGeneratedName(_ name: String, previousColors: Set<Ink>) -> Bool {
        let colors = Array(previousColors).sorted { $0.rawValue < $1.rawValue }
        let autoGeneratedName = Ink.generateDeckName(colors: colors)
        // 空の場合は自動生成された名前とみなす
        if autoGeneratedName.isEmpty {
            return name.isEmpty
        }
        return name == autoGeneratedName
    }

    // インクからデッキ名を更新
    private func updateDeckNameFromInkColors() {
        let colors = Array(selectedInkColors).sorted { $0.rawValue < $1.rawValue }
        newDeckName = Ink.generateDeckName(colors: colors)
    }

    private func createNewDeck() {
        let trimmedName = newDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
        let inkColors = Array(selectedInkColors).sorted { $0.rawValue < $1.rawValue }

        // 名前が空でインクも選択されていない場合は作成不可
        guard !trimmedName.isEmpty || !inkColors.isEmpty else { return }

        let newDeck = Deck(name: trimmedName, inkColors: inkColors)
        viewModel.addDeck(newDeck)
        isNewDeckSheetPresented = false
        newDeckName = ""
        selectedInkColors.removeAll()
        previousInkColors.removeAll()
    }
}

// デッキ行ビュー（リスト表示用）
struct DeckRowView: View {
    let deck: Deck

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 8) {
                // デッキ名
                Text(deck.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                // デッキ情報
                HStack(spacing: 16) {
                    // インク表示（枚数の左側）
                    if !deck.inkColors.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(deck.inkColors, id: \.self) { ink in
                                Circle()
                                    .fill(ink.color)
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "rectangle.stack")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text(String(format: String(localized: "%lld枚"), deck.totalCardCount))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if !deck.entries.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(formatDate(deck.updatedAt))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    DeckListView()
}
