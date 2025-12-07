//
//  DisclaimerView.swift
//  LoaPalette
//
//  Created by Auto on 2025/01/XX.
//

import SwiftUI

struct DisclaimerView: View {
    var body: some View {
        LegalContentView(
            remoteConfigKey: "disclaimer_content",
            navigationTitle: "免責事項"
        )
    }
}

#Preview {
    NavigationStack {
        DisclaimerView()
    }
}
