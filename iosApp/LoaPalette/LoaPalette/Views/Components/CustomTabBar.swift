
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @State private var showSearch: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // タブバー（4つのタブ）
            HStack(spacing: 0) {
                ForEach(0..<4) { index in
                    TabBarItem(
                        index: index,
                        isSelected: selectedTab == index,
                        action: {
                            selectedTab = index
                        }
                    )
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.black.opacity(0.9))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
            )
            
            // 検索ボタン
            Button(action: {
                showSearch = true
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.9))
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            )
                    )
            }
            .sheet(isPresented: $showSearch) {
                CardSearchView()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Color.black
                .ignoresSafeArea(edges: .bottom)
        )
    }
}

struct TabBarItem: View {
    let index: Int
    let isSelected: Bool
    let action: () -> Void
    
    private var tabInfo: (icon: String, label: String) {
        switch index {
        case 0:
            return ("diamond.fill", String(localized: "ロアカウンター"))
        case 1:
            return ("circle.fill", String(localized: "デッキリスト"))
        case 2:
            return ("triangle.fill", String(localized: "ニュース"))
        case 3:
            return ("gearshape.fill", String(localized: "設定"))
        default:
            return ("circle.fill", "")
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: tabInfo.icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .blue : .white)
                
                Text(tabInfo.label)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(isSelected ? .blue : .white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.15))
                    }
                }
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    CustomTabBar(selectedTab: .constant(0))
        .background(Color.black)
}

