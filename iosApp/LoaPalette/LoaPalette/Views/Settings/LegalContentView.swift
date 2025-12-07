//
//  LegalContentView.swift
//  LoaPalette
//
//  Created by Auto on 2025/01/XX.
//

import Foundation
import SwiftUI

/// 免責事項・プライバシーポリシー・利用規約の共通ビュー
struct LegalContentView: View {
    let remoteConfigKey: String
    let navigationTitle: String
    
    @State private var content: LegalContent?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let content = content {
                    Text(content.title)
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 8)
                    
                    if let introduction = content.introduction {
                        Text(introduction)
                            .padding(.bottom, 8)
                    }
                    
                    ForEach(content.sections, id: \.title) { section in
                        sectionView(section)
                    }
                    
                    Text("最終更新日: \(content.lastUpdated)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 16)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(navigationTitle)
        #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
        #endif
        .onAppear {
            loadContent()
        }
    }
    
    private func loadContent() {
        // Remote Configから取得を試みる
        let jsonString = RemoteConfigManager.shared.getString(forKey: remoteConfigKey)
        
        if !jsonString.isEmpty, let parsedContent = LegalContent.fromJSON(jsonString) {
            content = parsedContent
        } else {
            // デフォルト値を使用（sharedモジュールのRemoteConfigDefaultsから取得）
            let defaultJSON = RemoteConfigManager.shared.getDefaultValue(forKey: remoteConfigKey)
            if !defaultJSON.isEmpty, let parsedContent = LegalContent.fromJSON(defaultJSON) {
                content = parsedContent
            }
        }
    }
    
    private func sectionView(_ section: LegalSection) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionTitle(section.title)
            // 改行を処理して表示
            ForEach(section.content.components(separatedBy: "\n"), id: \.self) { line in
                if line.hasPrefix("•") {
                    Text(line)
                        .padding(.leading, 16)
                } else {
                    Text(line)
                }
            }
        }
        .padding(.bottom, 8)
    }
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .bold()
            .padding(.top, 8)
    }
}

#Preview("免責事項") {
    NavigationStack {
        LegalContentView(
            remoteConfigKey: "disclaimer_content",
            navigationTitle: "免責事項"
        )
    }
}

#Preview("プライバシーポリシー") {
    NavigationStack {
        LegalContentView(
            remoteConfigKey: "privacy_policy_content",
            navigationTitle: "プライバシーポリシー"
        )
    }
}

#Preview("利用規約") {
    NavigationStack {
        LegalContentView(
            remoteConfigKey: "terms_of_service_content",
            navigationTitle: "利用規約"
        )
    }
}

