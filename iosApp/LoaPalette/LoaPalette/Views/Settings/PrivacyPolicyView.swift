//
//  PrivacyPolicyView.swift
//  LoaPalette
//
//  Created by Auto on 2025/01/XX.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        LegalContentView(
            remoteConfigKey: "privacy_policy_content",
            navigationTitle: "プライバシーポリシー"
        )
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
