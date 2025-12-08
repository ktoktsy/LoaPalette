//
//  CardSearchFilterAccessoryView.swift
//  LoaPalette
//
//  Created by 片岡寿哉 on 2025/12/01.
//

import SwiftUI

#if canImport(UIKit)
    import UIKit
#endif

// Double Range Sliderコンポーネント.
struct DoubleRangeSlider: View {
    @Binding var minValue: Int
    @Binding var maxValue: Int
    let range: ClosedRange<Int>

    @State private var isDraggingMin: Bool = false
    @State private var isDraggingMax: Bool = false

    private let trackHeight: CGFloat = 6
    private let thumbSize: CGFloat = 28
    private let thumbTouchArea: CGFloat = 44
    private let padding: CGFloat = 14

    // ハプティックフィードバックジェネレーター.
    #if canImport(UIKit)
        private let impactFeedback = UIImpactFeedbackGenerator(style: .light)
    #endif

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let availableWidth = width - padding * 2
            let rangeWidth = CGFloat(range.upperBound - range.lowerBound)

            // 位置計算（パディングを考慮）.
            let minPosition =
                padding + CGFloat(minValue - range.lowerBound) / rangeWidth * availableWidth
            let maxPosition =
                padding + CGFloat(maxValue - range.lowerBound) / rangeWidth * availableWidth

            ZStack(alignment: .leading) {
                // 背景トラック.
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: trackHeight)
                    .frame(width: availableWidth)
                    .offset(x: padding)

                // 選択範囲トラック.
                Capsule()
                    .fill(Color.accentColor)
                    .frame(height: trackHeight)
                    .frame(width: max(maxPosition - minPosition, 0))
                    .offset(x: minPosition)

                // 最小値つまみ.
                thumbView(
                    position: minPosition,
                    value: minValue,
                    isActive: isDraggingMin
                )
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            isDraggingMin = true
                            let dragLocation = gesture.location.x
                            let normalizedValue = (dragLocation - padding) / availableWidth
                            let newValue =
                                Int(round(normalizedValue * rangeWidth)) + range.lowerBound
                            let clampedValue = max(
                                range.lowerBound, min(newValue, range.upperBound))

                            // 最小値つまみを優先的に動かす（最大値と同じ値でも動かせる）
                            minValue = clampedValue
                            // 最小値が最大値を超えた場合のみ、最大値を更新
                            if minValue > maxValue {
                                maxValue = minValue
                            }
                        }
                        .onEnded { _ in
                            isDraggingMin = false
                        }
                )

                // 最大値つまみ.
                thumbView(
                    position: maxPosition,
                    value: maxValue,
                    isActive: isDraggingMax
                )
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            isDraggingMax = true
                            let dragLocation = gesture.location.x
                            let normalizedValue = (dragLocation - padding) / availableWidth
                            let newValue =
                                Int(round(normalizedValue * rangeWidth)) + range.lowerBound
                            let clampedValue = max(
                                range.lowerBound, min(newValue, range.upperBound))

                            // 最大値つまみを優先的に動かす（最小値と同じ値でも動かせる）
                            maxValue = clampedValue
                            // 最大値が最小値を下回った場合のみ、最小値を更新
                            if maxValue < minValue {
                                minValue = maxValue
                            }
                        }
                        .onEnded { _ in
                            isDraggingMax = false
                        }
                )
            }
            .frame(height: thumbTouchArea)
            .onAppear {
                #if canImport(UIKit)
                    impactFeedback.prepare()
                #endif
            }
            .onChange(of: minValue) { oldValue, newValue in
                if isDraggingMin && oldValue != newValue {
                    #if canImport(UIKit)
                        impactFeedback.impactOccurred()
                    #endif
                }
            }
            .onChange(of: maxValue) { oldValue, newValue in
                if isDraggingMax && oldValue != newValue {
                    #if canImport(UIKit)
                        impactFeedback.impactOccurred()
                    #endif
                }
            }
        }
    }

    // つまみビュー.
    @ViewBuilder
    private func thumbView(position: CGFloat, value: Int, isActive: Bool) -> some View {
        ZStack {
            // タッチ領域（見えないが広い）.
            Circle()
                .fill(Color.clear)
                .frame(width: thumbTouchArea, height: thumbTouchArea)

            // つまみ本体.
            ZStack {
                Circle()
                    .fill(Color.white)
                    .shadow(
                        color: Color.black.opacity(isActive ? 0.25 : 0.15),
                        radius: isActive ? 6 : 4, x: 0, y: 2)

                Circle()
                    .stroke(Color.accentColor, lineWidth: isActive ? 3 : 2)

                // 値表示（ドラッグ中のみ）.
                if isActive {
                    Text("\(value)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.accentColor)
                }
            }
            .frame(width: thumbSize, height: thumbSize)
            .scaleEffect(isActive ? 1.15 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
        }
        .offset(x: position - thumbSize / 2, y: 0)
    }
}

// カード検索用のフィルターシートビュー.
struct CardSearchFilterAccessoryView: View {
    // フィルター状態を外部からバインディングで受け取る.
    @Binding var selectedFilters: Set<Filter>
    @Binding var nameQuery: String
    @Binding var minCost: Int
    @Binding var maxCost: Int
    @Binding var selectedTypes: Set<CardType>
    @Binding var selectedRarities: Set<Rarity>
    @Binding var inkableFilter: InkableFilter
    @Binding var minStrength: Int
    @Binding var maxStrength: Int
    @Binding var minWillpower: Int
    @Binding var maxWillpower: Int
    @Binding var minLore: Int
    @Binding var maxLore: Int
    @Binding var setName: String
    @Binding var artist: String

    // フィルター選択時に呼ばれるコールバック.
    let onSelect: (String) -> Void

    // インクカラーフィルター定義.
    enum Filter: String, CaseIterable, Identifiable {
        case amber = "Amber"
        case amethyst = "Amethyst"
        case ruby = "Ruby"
        case sapphire = "Sapphire"
        case steel = "Steel"
        case emerald = "Emerald"

        var id: String { rawValue }

        var displayName: String {
            rawValue
        }

        // Lorcana API searchパラメータ用クエリ文字列.
        // インクは color~amethyst のように部分一致指定する（APIレスポンスは "Amber, Steel" のような複数色カンマ区切り）.
        // 複数色は (color~amber;|color~steel;) のようにOR連結.
        // 参考: https://api-lorcana.com/#/Cards/get%20cards
        var searchClause: String {
            let colorValue = rawValue.lowercased()
            return "color~\(colorValue)"
        }
    }

    // カードタイプフィルター定義.
    enum CardType: String, CaseIterable, Identifiable {
        case character = "Character"
        case action = "Action"
        case item = "Item"
        case location = "Location"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .character: return String(localized: "キャラクター")
            case .action: return String(localized: "アクション")
            case .item: return String(localized: "アイテム")
            case .location: return String(localized: "ロケーション")
            }
        }

        var searchClause: String {
            return "type=\(rawValue)"
        }
    }

    // レアリティフィルター定義.
    enum Rarity: String, CaseIterable, Identifiable {
        case common = "Common"
        case uncommon = "Uncommon"
        case rare = "Rare"
        case superRare = "Super Rare"
        case legendary = "Legendary"
        // TODO: APIにEnchantedレアリティが存在しないため、一時的にUIから非表示.
        // APIに追加された場合はallCasesのカスタム実装も削除.

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .common: return String(localized: "コモン")
            case .uncommon: return String(localized: "アンコモン")
            case .rare: return String(localized: "レア")
            case .superRare: return String(localized: "スーパーレア")
            case .legendary: return String(localized: "レジェンダリー")
            }
        }

        var searchClause: String {
            // APIのsearchパラメータでrarity=は動作しない場合があるため、部分一致（~）を使用.
            // 例: rarity~Enchanted, rarity~Super Rare
            return "rarity~\(rawValue)"
        }

        // TODO: EnchantedがAPIに追加されたら、このカスタム実装を削除してCaseIterableのデフォルトallCasesを使用.
        // UI表示用のallCases（Enchantedを除外）.
        static var allCases: [Rarity] {
            return [.common, .uncommon, .rare, .superRare, .legendary]
        }
    }

    // インク可能フィルター定義.
    enum InkableFilter: String, CaseIterable {
        case any = "any"
        case inkable = "true"
        case notInkable = "false"

        var displayName: String {
            switch self {
            case .any: return String(localized: "条件なし")
            case .inkable: return String(localized: "インク可能")
            case .notInkable: return String(localized: "インク不可")
            }
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // グラバー.
            Capsule()
                .fill(Color.secondary.opacity(0.35))
                .frame(width: 36, height: 4)
                .padding(.top, 8)

            // タイトル.
            Text(String(localized: "詳細検索"))
                .font(.headline)
                .padding(.top, 4)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    // カード名.
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "カード名"))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        TextField(String(localized: "名前に含まれるテキスト（英語）"), text: $nameQuery)
                            .textFieldStyle(.roundedBorder)
                            .padding(.trailing, 4)
                    }
                    .padding(.horizontal, 16)

                    // コスト.
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(String(localized: "コスト"))
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()

                            // 現在の値を表示.
                            if minCost == 0 && maxCost == 10 {
                                Text(String(localized: "条件なし"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(
                                    String(
                                        format: String(localized: "%lld 〜 %lld"), minCost, maxCost)
                                )
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.accentColor.opacity(0.15))
                                )
                            }
                        }

                        // Double Range Slider.
                        DoubleRangeSlider(
                            minValue: $minCost,
                            maxValue: $maxCost,
                            range: 0...10
                        )
                        .frame(height: 44)
                    }
                    .padding(.horizontal, 16)

                    // インクカラー.
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "インク"))
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Filter.allCases) { filter in
                                filterChip(for: filter)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, 16)

                    // カードタイプ.
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "タイプ"))
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 2)

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(CardType.allCases) { type in
                                typeChip(for: type)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, 16)

                    // レアリティ.
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "レアリティ"))
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(Rarity.allCases) { rarity in
                                rarityChip(for: rarity)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.top, 2)
                    }
                    .padding(.horizontal, 16)

                    // インク可能.
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "インク可能"))
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Picker(String(localized: "インク可能"), selection: $inkableFilter) {
                            ForEach(InkableFilter.allCases, id: \.self) { filter in
                                Text(filter.displayName).tag(filter)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, 16)

                    // 攻撃力.
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(String(localized: "攻撃力"))
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()

                            if minStrength == 0 && maxStrength == 20 {
                                Text(String(localized: "条件なし"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(
                                    String(
                                        format: String(localized: "%lld 〜 %lld"), minStrength,
                                        maxStrength)
                                )
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.accentColor.opacity(0.15))
                                )
                            }
                        }

                        DoubleRangeSlider(
                            minValue: $minStrength,
                            maxValue: $maxStrength,
                            range: 0...20
                        )
                        .frame(height: 44)
                    }
                    .padding(.horizontal, 16)

                    // 防御力.
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(String(localized: "防御力"))
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()

                            if minWillpower == 0 && maxWillpower == 20 {
                                Text(String(localized: "条件なし"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(
                                    String(
                                        format: String(localized: "%lld 〜 %lld"), minWillpower,
                                        maxWillpower)
                                )
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.accentColor.opacity(0.15))
                                )
                            }
                        }

                        DoubleRangeSlider(
                            minValue: $minWillpower,
                            maxValue: $maxWillpower,
                            range: 0...20
                        )
                        .frame(height: 44)
                    }
                    .padding(.horizontal, 16)

                    // ロア.
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(String(localized: "ロア"))
                                .font(.subheadline)
                                .foregroundColor(.primary)

                            Spacer()

                            if minLore == 0 && maxLore == 5 {
                                Text(String(localized: "条件なし"))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else {
                                Text(
                                    String(
                                        format: String(localized: "%lld 〜 %lld"), minLore, maxLore)
                                )
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.accentColor.opacity(0.15))
                                )
                            }
                        }

                        DoubleRangeSlider(
                            minValue: $minLore,
                            maxValue: $maxLore,
                            range: 0...5
                        )
                        .frame(height: 44)
                    }
                    .padding(.horizontal, 16)

                    // セット名.
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "セット名"))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        TextField(String(localized: "セット名で検索"), text: $setName)
                            .textFieldStyle(.roundedBorder)
                            .padding(.trailing, 4)
                    }
                    .padding(.horizontal, 16)

                    // イラストレーター.
                    VStack(alignment: .leading, spacing: 6) {
                        Text(String(localized: "イラストレーター"))
                            .font(.subheadline)
                            .foregroundColor(.primary)
                        TextField(String(localized: "イラストレーター名で検索"), text: $artist)
                            .textFieldStyle(.roundedBorder)
                            .padding(.trailing, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
                .padding(.top, 8)
            }

            Divider()
                .padding(.horizontal, 16)

            // アクションボタン.
            HStack(spacing: 12) {
                Button {
                    clearAll()
                } label: {
                    Text(String(localized: "条件をクリア"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.08))
                        )
                }

                Button {
                    let query = buildSearchQuery()
                    onSelect(query)
                } label: {
                    Text(String(localized: "この条件で検索"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.9))
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.7)
                .ignoresSafeArea()
        )
    }

    // フィルターチップ.
    private func filterChip(for filter: Filter) -> some View {
        let isSelected = selectedFilters.contains(filter)

        return Button {
            if isSelected {
                // 同じフィルターを再タップで解除.
                selectedFilters.remove(filter)
            } else {
                selectedFilters.insert(filter)
            }
        } label: {
            HStack(spacing: 6) {
                Circle()
                    .fill(color(for: filter))
                    .frame(width: 8, height: 8)

                Text(filter.displayName)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 999)
                    .fill(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 999)
                    .stroke(Color.white.opacity(isSelected ? 0.6 : 0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // タイプチップ.
    private func typeChip(for type: CardType) -> some View {
        let isSelected = selectedTypes.contains(type)

        return Button {
            if isSelected {
                selectedTypes.remove(type)
            } else {
                selectedTypes.insert(type)
            }
        } label: {
            Text(type.displayName)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 999)
                        .fill(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(Color.white.opacity(isSelected ? 0.6 : 0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // レアリティチップ.
    private func rarityChip(for rarity: Rarity) -> some View {
        let isSelected = selectedRarities.contains(rarity)

        return Button {
            if isSelected {
                selectedRarities.remove(rarity)
            } else {
                selectedRarities.insert(rarity)
            }
        } label: {
            Text(rarity.displayName)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 999)
                        .fill(isSelected ? Color.white.opacity(0.9) : Color.white.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 999)
                        .stroke(Color.white.opacity(isSelected ? 0.6 : 0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // インク定義
    private func color(for filter: Filter) -> Color {
        switch filter {
        case .amber: return Color.orange
        case .amethyst: return Color.purple
        case .ruby: return Color.red
        case .sapphire: return Color.blue
        case .steel: return Color.gray
        case .emerald: return Color.green
        }
    }

    // 検索クエリ組み立て.
    private func buildSearchQuery() -> String {
        var clauses: [String] = []

        // カード名部分一致.
        let trimmedName = nameQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            clauses.append("name~\(trimmedName)")
        }

        // コスト範囲.
        if !(minCost == 0 && maxCost == 10) {
            if minCost > 0 {
                clauses.append("cost>=\(minCost)")
            }
            if maxCost < 10 {
                clauses.append("cost<=\(maxCost)")
            }
        }

        // 攻撃力範囲.
        if !(minStrength == 0 && maxStrength == 20) {
            if minStrength > 0 {
                clauses.append("strength>=\(minStrength)")
            }
            if maxStrength < 20 {
                clauses.append("strength<=\(maxStrength)")
            }
        }

        // 防御力範囲.
        if !(minWillpower == 0 && maxWillpower == 20) {
            if minWillpower > 0 {
                clauses.append("willpower>=\(minWillpower)")
            }
            if maxWillpower < 20 {
                clauses.append("willpower<=\(maxWillpower)")
            }
        }

        // ロア範囲.
        if !(minLore == 0 && maxLore == 5) {
            if minLore > 0 {
                clauses.append("lore>=\(minLore)")
            }
            if maxLore < 5 {
                clauses.append("lore<=\(maxLore)")
            }
        }

        // セット名.
        let trimmedSetName = setName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedSetName.isEmpty {
            clauses.append("set_name~\(trimmedSetName)")
        }

        // イラストレーター.
        let trimmedArtist = artist.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedArtist.isEmpty {
            clauses.append("artist~\(trimmedArtist)")
        }

        // インク可能.
        if inkableFilter != .any {
            clauses.append("inkable=\(inkableFilter.rawValue)")
        }

        // インクカラー（複数選択対応）.
        let colorFilters = Array(selectedFilters)
        var colorClause: String?

        if colorFilters.count == 1 {
            colorClause = colorFilters[0].searchClause
        } else if colorFilters.count > 1 {
            let orClauses = colorFilters.map { $0.searchClause }
            if clauses.isEmpty {
                colorClause = orClauses.joined(separator: ";|")
            } else {
                let inner = orClauses.joined(separator: ";|")
                colorClause = "(\(inner);)"
            }
        }

        // カードタイプ（複数選択対応）.
        let typeFilters = Array(selectedTypes)
        var typeClause: String?

        if typeFilters.count == 1 {
            typeClause = typeFilters[0].searchClause
        } else if typeFilters.count > 1 {
            let orClauses = typeFilters.map { $0.searchClause }
            if clauses.isEmpty && colorClause == nil {
                typeClause = orClauses.joined(separator: ";|")
            } else {
                let inner = orClauses.joined(separator: ";|")
                typeClause = "(\(inner);)"
            }
        }

        // レアリティ（複数選択対応）.
        let rarityFilters = Array(selectedRarities)
        var rarityClause: String?

        if rarityFilters.count == 1 {
            rarityClause = rarityFilters[0].searchClause
        } else if rarityFilters.count > 1 {
            let orClauses = rarityFilters.map { $0.searchClause }
            if clauses.isEmpty && colorClause == nil && typeClause == nil {
                rarityClause = orClauses.joined(separator: ";|")
            } else {
                let inner = orClauses.joined(separator: ";|")
                rarityClause = "(\(inner);)"
            }
        }

        // OR条件をまとめる.
        var orClauses: [String] = []
        if let colorClause = colorClause {
            orClauses.append(colorClause)
        }
        if let typeClause = typeClause {
            orClauses.append(typeClause)
        }
        if let rarityClause = rarityClause {
            orClauses.append(rarityClause)
        }

        // クエリ組み立て.
        var result: [String] = []
        result.append(contentsOf: clauses)

        if orClauses.count == 1 {
            result.append(orClauses[0])
        } else if orClauses.count > 1 {
            let inner = orClauses.joined(separator: ";|")
            result.append("(\(inner);)")
        }

        return result.joined(separator: ";")
    }

    // 条件リセット.
    private func clearAll() {
        selectedFilters = []
        nameQuery = ""
        minCost = 0
        maxCost = 10
        selectedTypes = []
        selectedRarities = []
        inkableFilter = .any
        minStrength = 0
        maxStrength = 20
        minWillpower = 0
        maxWillpower = 20
        minLore = 0
        maxLore = 5
        setName = ""
        artist = ""
        // クリア時も検索を実行して全件表示.
        onSelect("")
    }
}

// iOS 16 以降ではシートの高さをデタント指定.
@available(iOS 16.0, *)
private struct FilterSheetDetentsModifierImpl: ViewModifier {
    func body(content: Content) -> some View {
        content
            .presentationDetents([.medium, .large])
    }
}

/// iOS 15 〜 でもコンパイル可能なデタント用モディファイア.
struct FilterSheetDetentsModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.modifier(FilterSheetDetentsModifierImpl())
        } else {
            content
        }
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.9).ignoresSafeArea()
        VStack {
            Spacer()
            CardSearchFilterAccessoryView(
                selectedFilters: .constant([]),
                nameQuery: .constant(""),
                minCost: .constant(0),
                maxCost: .constant(10),
                selectedTypes: .constant([]),
                selectedRarities: .constant([]),
                inkableFilter: .constant(.any),
                minStrength: .constant(0),
                maxStrength: .constant(20),
                minWillpower: .constant(0),
                maxWillpower: .constant(20),
                minLore: .constant(0),
                maxLore: .constant(5),
                setName: .constant(""),
                artist: .constant(""),
                onSelect: { _ in }
            )
        }
    }
}
