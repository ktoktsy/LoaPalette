//
//  SettingsView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/11/28.
//

import SwiftUI

private enum SettingsItem: Identifiable {
    case officialSite
    case contact

    var id: String {
        switch self {
        case .officialSite:
            return "officialSite"
        case .contact:
            return "contact"
        }
    }
}

struct SettingsView: View {
    private let items: [SettingsItem] = [
        .officialSite,
        .contact,
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ForEach(items) { item in
                        switch item {
                        case .officialSite:
                            officialSite()
                        case .contact:
                            contact()
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle(String(localized: "設定"))
        }
    }

    private func officialSite() -> some View {
        Link(
            destination: URL(
                string: "https://www.takaratomy.co.jp/products/disneylorcana/")!
        ) {
            cell(
                title: String(localized: "公式サイト"),
                systemName: "chevron.right"
            )
        }
    }

    private func contact() -> some View {
        // TODO: GoogleForm作成
        Link(
            destination: URL(string: "https://example.com/contact")!
        ) {
            cell(
                title: String(localized: "要望/お問い合わせ"),
                systemName: "chevron.right"
            )
        }
    }

    private func cell(title: String, systemName: String?) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.white)
            Spacer()
            if let systemName {
                Image(systemName: systemName)
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    SettingsView()
}
