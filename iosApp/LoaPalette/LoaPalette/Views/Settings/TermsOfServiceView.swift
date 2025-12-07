//
//  TermsOfServiceView.swift
//  LoaPalette
//
//  Created by Auto on 2025/01/XX.
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        LegalContentView(
            remoteConfigKey: "terms_of_service_content",
            navigationTitle: "利用規約"
        )
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}
