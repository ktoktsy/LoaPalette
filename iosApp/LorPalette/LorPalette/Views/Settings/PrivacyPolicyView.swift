
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
