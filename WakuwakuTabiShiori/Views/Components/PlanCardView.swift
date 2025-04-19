//  トップページで使う予定カード
//  PlanCardView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData // Planモデルを使うため (Preview用)

struct PlanCardView: View {
    let plan: Plan
    // 現在の日付を比較用に取得 (毎秒更新は不要なので@Stateは使わない)
    private let today = Calendar.current.startOfDay(for: Date())

    // --- デザイン設定値 (調整可能) ---
    private var cornerRadius: CGFloat = 20
    private var shadowRadius: CGFloat = 8
    private var shadowY: CGFloat = 5
    
    init(plan: Plan) {
        self.plan = plan
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) { // 要素を重ね、左下に揃える
            // --- 1. 背景レイヤー ---
            backgroundLayer

            // --- 2. コンテンツレイヤー ---
            contentLayer
                .padding() // 内側に余白

        }
        .frame(width: 180, height: 220) // カードのサイズを指定 (調整可能)
        .cornerRadius(cornerRadius)
        .shadow(color: themeColor.opacity(0.4), radius: shadowRadius, x: 0, y: shadowY)
        // タップ時のアニメーションは任意 (ListやScrollView側で制御することも多い)
        // .scaleEffect(isPressed ? 0.98 : 1.0) // 例
    }

    // MARK: - Private Computed Properties & Functions

    // テーマ名に基づいて色を決定 (実際にはHelperやPlanの拡張で管理推奨)
    private var themeColor: Color {
        switch plan.themeName {
        case "Sea": return .blue
        case "Cafe": return .brown
        case "Forest": return .green
        case "City": return .purple
        case "Sweet": return .pink
        default: return .indigo // デフォルトの色
        }
    }

    // 開始日までの残り日数を計算 (過去ならnil)
    private var daysUntilStartDate: Int? {
        // 開始日も「0日」として含める場合
        let components = Calendar.current.dateComponents([.day], from: today, to: Calendar.current.startOfDay(for: plan.startDate))
        guard let days = components.day, days >= 0 else {
            return nil // 開始日が過去の場合はnil
        }
        return days
    }

    // MARK: - View Components

    // 背景レイヤー
    private var backgroundLayer: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            // グラデーションで少しリッチに
            .fill(themeColor.gradient)
            // テーマアイコンを薄く表示しても面白いかも (オプション)
            /*
            .overlay(
                Image(systemName: themeIconName) // themeIconNameを計算する処理が必要
                    .font(.system(size: 80))
                    .foregroundColor(.white.opacity(0.15))
                    .rotationEffect(.degrees(-20))
                    .offset(x: 40, y: -30),
                alignment: .topLeading
            )
             */
            .clipped() // overlayがはみ出さないように
    }

    // コンテンツレイヤー (テキストやカウントダウン)
    private var contentLayer: some View {
        VStack(alignment: .leading, spacing: 8) {
            Spacer() // 上にスペースを空けて、コンテンツを下寄せにする

            // --- タイトル ---
            Text(plan.title)
                .font(.title3) // 少し大きめ
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(2) // 2行まで表示
                .minimumScaleFactor(0.8) // 文字が収まらない場合に縮小

            // --- 日付 ---
            Text("\(plan.startDate, style: .date) - \(plan.endDate, style: .date)")
                .font(.caption) // 小さめ
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8)) // 少し透明にする

            // --- カウントダウン表示 (未来の予定の場合のみ) ---
            if let days = daysUntilStartDate {
                HStack {
                    Spacer() // 右寄せにする
                    Text(days == 0 ? "今日！" : "あと \(days) 日")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeColor) // テーマカラーを文字色に
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.white.opacity(0.9)) // 白い背景
                        .clipShape(Capsule()) // カプセル形状
                        .shadow(radius: 3)
                        // 登場アニメーション (任意)
                        .transition(.scale.combined(with: .opacity))
                }
                .padding(.top, 5)
            }
        }
        // カウントダウン表示時にアニメーションを有効にする (任意)
        // .animation(.spring(), value: daysUntilStartDate)
    }
}

// MARK: - Preview

#Preview {
    // サンプルデータを複数用意
    let samplePlan1 = Plan(title: "沖縄シーサイドバカンス🏖️", startDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!, endDate: Calendar.current.date(byAdding: .day, value: 10, to: Date())!, themeName: "Sea")
    let samplePlan2 = Plan(title: "京都カフェ巡り☕️", startDate: Calendar.current.date(byAdding: .day, value: 0, to: Date())!, endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, themeName: "Cafe")
    let samplePlan3 = Plan(title: "夏の終わりのキャンプ🏕️", startDate: Calendar.current.date(byAdding: .day, value: 30, to: Date())!, endDate: Calendar.current.date(byAdding: .day, value: 32, to: Date())!, themeName: "Forest")
    let samplePlan4 = Plan(title: "大阪くいだおれ旅行🐙（過去）", startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!, endDate: Calendar.current.date(byAdding: .day, value: -8, to: Date())!, themeName: "City")
    let samplePlan5 = Plan(title: "スイーツ食べ歩き🍓", startDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, endDate: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, themeName: "Sweet")

    // 横スクロールで表示確認
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 15) {
            PlanCardView(plan: samplePlan1)
            PlanCardView(plan: samplePlan2)
            PlanCardView(plan: samplePlan3)
            PlanCardView(plan: samplePlan4) // 過去の予定 (カウントダウンなし)
            PlanCardView(plan: samplePlan5)
        }
        .padding()
    }
    // プレビュー用にSwiftDataの環境を設定 (Planが@Modelの場合)
    // .modelContainer(for: Plan.self, inMemory: true)
    // ※ PreviewでSwiftDataを使うには追加設定が必要な場合があります
    //   簡単にするため、Plan構造体を一時的に@Modelなしで定義するのも手です
    /*
     struct Plan: Identifiable { // Preview用の簡易版
         var id: UUID = UUID()
         var title: String
         var startDate: Date
         var endDate: Date
         var themeName: String
         var budget: Double? = nil
         var createdAt: Date = Date()
     }
    */
}
