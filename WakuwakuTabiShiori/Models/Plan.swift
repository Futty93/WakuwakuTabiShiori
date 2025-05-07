//  予定全体のデータ (@Model)
//  Plan.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftData
import SwiftUI

@Model
final class Plan {
    var title: String
    var startDate: Date
    var endDate: Date
    var themeName: String // テーマ識別子 (例: "Sea", "Cafe")
    var themeColorData: Data? // Colorを直接保存できないためDataに変換
    var budget: Double? // 目安予算 (任意)
    var memo: String?
    private var memberIdsData: Data? // ユーザーID配列（将来的にはUserモデルへの参照）
    
    @Relationship(deleteRule: .cascade, inverse: \Schedule.plan)
    var schedules: [Schedule] = [] // 日程リスト (Planが消えたらScheduleも消す)
    var createdAt: Date // 作成日時 (ソート用)
    var updatedAt: Date // 更新日時
    var isShared: Bool = false // 共有されているかどうか
    

    init(title: String = "", startDate: Date = Date(), endDate: Date = Date(), themeName: String = "Default", themeColorData: Data? = nil, budget: Double? = nil, memo: String? = nil, memberIds: [String] = [], createdAt: Date = Date(), updatedAt: Date = Date(), isShared: Bool = false) {
            // --- まず全ての格納プロパティを初期化 ---
            self.title = title
            self.startDate = startDate
            self.endDate = endDate
            self.themeName = themeName
            self.themeColorData = themeColorData // nil許容
            self.budget = budget                 // nil許容
            self.memo = memo                     // nil許容
            self.memberIdsData = nil             // ← memberIdsData を nil で初期化
            // self.schedules = [] // デフォルト値があるので省略可 or 明示的に書いてもOK
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.isShared = isShared

            // --- 全ての格納プロパティ初期化後に、計算型プロパティのsetを呼ぶ ---
            self.memberIds = memberIds // ← 最後に移動
        }
    
    @Transient // SwiftDataにこのプロパティを無視させる
    var memberIds: [String]? {
        // get: Data -> [String]? にデコード
        get {
            guard let data = memberIdsData else { return nil } // データがなければnil
            do {
                // JSONDecoderを使ってDataから[String]に変換
                return try JSONDecoder().decode([String].self, from: data)
            } catch {
                print("❌ Failed to decode memberIds: \(error)")
                return nil // デコード失敗時もnil
            }
        }
        // set: [String]? -> Data? にエンコード
        set {
            guard let newValue = newValue else {
                // 新しい値がnilならDataもnilにする
                memberIdsData = nil
                return
            }
            do {
                // JSONEncoderを使って[String]をDataに変換
                memberIdsData = try JSONEncoder().encode(newValue)
            } catch {
                print("❌ Failed to encode memberIds: \(error)")
                memberIdsData = nil // エンコード失敗時はnilにする
            }
        }
    }

    // テーマカラーを取得するComputed Property
    var themeColor: Color {
        get {
            // Color+Themesの拡張メソッドを使用
            if let colorData = themeColorData {
                return Color.fromData(colorData)
            }
            // データがなければテーマ名から色を取得
            return Color.fromThemeName(themeName)
        }
        set {
            // Color+Themesの拡張メソッドを使用して変換
            themeColorData = newValue.toData()
        }
    }

    // 旅行の総日数を計算
    var totalDays: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return (components.day ?? 0) + 1 // 開始日も含める
    }

    // 総予算使用率を計算（オプショナル）
    var budgetUsagePercentage: Double? {
        guard let totalBudget = budget, totalBudget > 0 else { return nil }

        var totalCost: Double = 0
        schedules.forEach { schedule in
            schedule.items?.forEach { item in
                if let cost = item.cost {
                    totalCost += cost
                }
            }
        }

        return (totalCost / totalBudget) * 100
    }
}
