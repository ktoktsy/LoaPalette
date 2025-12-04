//
//  MatchRecordsFullScreenView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

// 試合記録フルスクリーンビュー
struct MatchRecordsFullScreenView: View {
    let deckId: String
    @ObservedObject var viewModel: DeckListViewModel
    let onDismiss: () -> Void
    
    @State private var filterType: MatchFilterType = .all  // フィルター状態

    private var deck: Deck? {
        viewModel.decks.first { $0.id == deckId }
    }
    
    // フィルタータイプ
    enum MatchFilterType {
        case all
        case wins
        case losses
    }

    var body: some View {
        NavigationStack {
            Group {
                if let deck = deck {
                    let sortedRecords = deck.matchRecords.sorted(by: { $0.playedAt > $1.playedAt })
                    
                    if sortedRecords.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "tray")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text(String(localized: "試合記録がありません"))
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // フィルター適用
                        let filteredRecords = filterRecords(sortedRecords)
                        
                        VStack(spacing: 0) {
                            // 統計情報（固定）
                            winLossStatsSection(deck: deck, filterType: $filterType)
                                .padding(.horizontal, 16)
                                .padding(.top, 8)
                                .padding(.bottom, 12)
                            
                            // 試合記録リスト（スクロール可能）
                            ScrollView(.vertical, showsIndicators: true) {
                                LazyVStack(spacing: 12) {
                                    ForEach(filteredRecords) { record in
                                        MatchRecordRow(record: record) {
                                            viewModel.removeMatchRecord(deck.id, recordId: record.id)
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                } else {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text(String(localized: "デッキを読み込み中..."))
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle(String(localized: "勝敗記録"))
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
            .onAppear {
                viewModel.loadDecks()
            }
        }
    }
    
    // フィルター適用
    private func filterRecords(_ records: [MatchRecord]) -> [MatchRecord] {
        switch filterType {
        case .all:
            return records
        case .wins:
            return records.filter { $0.isWin }
        case .losses:
            return records.filter { !$0.isWin }
        }
    }
    
    // 統計情報セクション
    private func winLossStatsSection(deck: Deck, filterType: Binding<MatchFilterType>) -> some View {
        HStack(spacing: 16) {
            // 勝利数
            Button {
                withAnimation {
                    filterType.wrappedValue = filterType.wrappedValue == .wins ? .all : .wins
                }
            } label: {
                VStack(spacing: 2) {
                    HStack(spacing: 3) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption2)
                        Text(String(localized: "勝利"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("\(deck.wins)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(filterType.wrappedValue == .wins ? Color.green.opacity(0.1) : Color.clear)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            Divider()
                .frame(height: 30)
            
            // 敗北数
            Button {
                withAnimation {
                    filterType.wrappedValue = filterType.wrappedValue == .losses ? .all : .losses
                }
            } label: {
                VStack(spacing: 2) {
                    HStack(spacing: 3) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption2)
                        Text(String(localized: "敗北"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text("\(deck.losses)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(filterType.wrappedValue == .losses ? Color.red.opacity(0.1) : Color.clear)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
            
            Divider()
                .frame(height: 30)
            
            // 勝率
            VStack(spacing: 2) {
                HStack(spacing: 3) {
                    Image(systemName: "chart.bar.fill")
                        .foregroundColor(.blue)
                        .font(.caption2)
                    Text(String(localized: "勝率"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Text(String(format: "%.1f%%", deck.winRate))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGroupedBackground))
        .cornerRadius(12)
    }
}

