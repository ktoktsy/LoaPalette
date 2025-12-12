
import SwiftUI

// 勝敗記録セクション
struct WinLossSectionView: View {
    let deck: Deck
    @ObservedObject var viewModel: DeckListViewModel
    @Binding var isExpanded: Bool
    @Binding var isAddMatchRecordPresented: Bool
    @Binding var isMatchRecordsFullScreenPresented: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(localized: "勝敗記録"))
                            .font(.headline)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    AnalyticsManager.shared.logMatchRecordAddButtonClick()
                    isAddMatchRecordPresented = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            
            if isExpanded {
                // 統計情報
                HStack(spacing: 20) {
                // 勝利数
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                        Text(String(localized: "勝利"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Text("\(deck.wins)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                .frame(maxWidth: .infinity)

                Divider()

                // 敗北数
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.caption)
                        Text(String(localized: "敗北"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Text("\(deck.losses)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                }
                .frame(maxWidth: .infinity)

                Divider()

                // 勝率
                VStack(spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                        Text(String(localized: "勝率"))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Text(String(format: "%.1f%%", deck.winRate))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .frame(maxWidth: .infinity)
                }
                .padding(.top, 4)

                // 試合記録リスト
                if deck.matchRecords.isEmpty {
                Text(String(localized: "試合記録がありません"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 16)
            } else {
                let sortedRecords = deck.matchRecords.sorted(by: { $0.playedAt > $1.playedAt })
                let displayRecords = Array(sortedRecords.prefix(2))
                
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 8) {
                        ForEach(displayRecords) { record in
                            MatchRecordRow(record: record) {
                                viewModel.removeMatchRecord(deck.id, recordId: record.id)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(
                    minHeight: 0,
                    maxHeight: 200
                )
                .padding(.top, 8)
                
                // 表示拡張ボタン（2件以上ある場合のみ表示）
                if sortedRecords.count > 2 {
                    Button {
                        AnalyticsManager.shared.logDeckDetailMoreButtonClick()
                        isMatchRecordsFullScreenPresented = true
                    } label: {
                        HStack {
                            Text(String(localized: "もっと見る"))
                                .font(.subheadline)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.bordered)
                    .padding(.top, 4)
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

