//
//  DeckSelectionView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

// デッキ選択ビュー（カードをデッキに追加する際に使用）
struct DeckSelectionView: View {
    let selectedCardIds: Set<String>
    let cards: [LorcanaCard]
    @ObservedObject var deckListViewModel: DeckListViewModel
    let onComplete: () -> Void

    @State private var selectedDeckId: String? = nil
    @State private var isNewDeckSheetPresented = false
    @State private var newDeckName: String = ""

    var selectedCards: [LorcanaCard] {
        cards.filter { selectedCardIds.contains($0.id) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if selectedCards.isEmpty {
                    emptyStateView
                } else {
                    selectedCardsList

                    Divider()

                    deckSelectionList
                }
            }
            .navigationTitle(String(localized: "デッキに追加"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "キャンセル")) {
                        onComplete()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "追加")) {
                        addCardsToDeck()
                    }
                    .disabled(selectedDeckId == nil)
                }
            }
            .sheet(isPresented: $isNewDeckSheetPresented) {
                newDeckSheet
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text(String(localized: "選択されたカードがありません"))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var selectedCardsList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(String(format: String(localized: "選択されたカード (%lld枚)"), selectedCards.count))
                .font(.headline)
                .padding(.horizontal)
                .padding(.top)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(selectedCards) { card in
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
                            .frame(width: 60, height: 90)
                            .cornerRadius(4)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGroupedBackground))
    }

    private var deckSelectionList: some View {
        List {
            Section {
                Button {
                    isNewDeckSheetPresented = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text(String(localized: "新しいデッキを作成"))
                            .foregroundColor(.primary)
                    }
                }
            }

            if deckListViewModel.decks.isEmpty {
                Section {
                    Text(String(localized: "デッキがありません"))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            } else {
                Section {
                    ForEach(deckListViewModel.decks) { deck in
                        Button {
                            selectedDeckId = deck.id
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(deck.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    Text(
                                        String(
                                            format: String(localized: "%lld枚"), deck.totalCardCount)
                                    )
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                }

                                Spacer()

                                if selectedDeckId == deck.id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private var newDeckSheet: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "デッキ名"), text: $newDeckName)
                }
            }
            .navigationTitle(String(localized: "新しいデッキ"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "キャンセル")) {
                        isNewDeckSheetPresented = false
                        newDeckName = ""
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "作成")) {
                        createNewDeck()
                    }
                    .disabled(newDeckName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func createNewDeck() {
        let trimmedName = newDeckName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let newDeck = Deck(name: trimmedName)
        deckListViewModel.addDeck(newDeck)
        selectedDeckId = newDeck.id
        isNewDeckSheetPresented = false
        newDeckName = ""
    }

    private func addCardsToDeck() {
        guard let deckId = selectedDeckId else { return }

        for card in selectedCards {
            deckListViewModel.addCardToDeck(deckId, card: card, count: 1)
        }

        // ハプティックフィードバック
        #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        #endif

        onComplete()
    }
}
