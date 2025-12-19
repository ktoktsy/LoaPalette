
import SwiftUI

struct NewsView: View {
    @State private var newsURL: URL?
    @State private var isLoading = true
    @State private var loadError: Error?

    var body: some View {
        Group {
            if let url = newsURL {
                WebView(url: url)
            } else if isLoading {
                ProgressView()
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.orange)
                    Text(String(localized: "ニュースの読み込みに失敗しました"))
                        .font(.headline)
                        .foregroundColor(.primary)
                    if let error = loadError {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                }
            }
        }
        .toolbar(.visible, for: .tabBar)
        .tabBarMinimizeBehavior(.onScrollDown)
        .onAppear {
            loadNewsURL()
        }
        .ignoresSafeArea()
    }

    private func loadNewsURL() {
        let urlString = ResourceManager.newsURL()
        guard let url = URL(string: urlString) else {
            loadError = NSError(
                domain: "NewsView",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "ニュースURLが無効です: \(urlString)"]
            )
            isLoading = false
            return
        }
        newsURL = url
        isLoading = false
    }
}

#Preview {
    NewsView()
}
