//
//  MatchRecordRow.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

// 試合記録行ビュー
struct MatchRecordRow: View {
    let record: MatchRecord
    let onDelete: () -> Void

    @State private var isDeleteAlertPresented = false

    var body: some View {
        HStack(spacing: 12) {
            // 勝敗アイコン
            Image(systemName: record.isWin ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(record.isWin ? .green : .red)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                // 相手のデッキ名
                if !record.opponentDeckName.isEmpty {
                    Text(record.opponentDeckName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                }

                // 相手のインク色と日時
                HStack(spacing: 4) {
                    if !record.opponentInkColors.isEmpty {
                        ForEach(record.opponentInkColors, id: \.self) { ink in
                            Circle()
                                .fill(ink.color)
                                .frame(width: 8, height: 8)
                        }
                    } else {
                        Text(String(localized: "インク未設定"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // 試合日時
                    Text(formatMatchDate(record.playedAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // 削除ボタン
            Button {
                isDeleteAlertPresented = true
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(8)
        .alert(String(localized: "試合記録を削除"), isPresented: $isDeleteAlertPresented) {
            Button(String(localized: "キャンセル"), role: .cancel) {}
            Button(String(localized: "削除"), role: .destructive) {
                onDelete()
            }
        } message: {
            Text(String(localized: "この試合記録を削除してもよろしいですか？"))
        }
    }

    private func formatMatchDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

