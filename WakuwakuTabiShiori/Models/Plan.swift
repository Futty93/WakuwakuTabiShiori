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
    var id: UUID
    var title: String
    var startDate: Date
    var endDate: Date
    var themeName: String // テーマ識別子 (例: "Sea", "Cafe")
    var themeColorData: Data? // Colorを直接保存できないためDataに変換
    var budget: Double? // 目安予算 (任意)
    var memberIds: [String] = [] // ユーザーID配列（将来的にはUserモデルへの参照）
    @Relationship(deleteRule: .cascade) var schedules: [Schedule]? = [] // 日程リスト (Planが消えたらScheduleも消す)
    var createdAt: Date // 作成日時 (ソート用)
    var updatedAt: Date // 更新日時
    var isShared: Bool = false // 共有されているかどうか

    init(id: UUID = UUID(), title: String = "", startDate: Date = Date(), endDate: Date = Date(), themeName: String = "Default", themeColorData: Data? = nil, budget: Double? = nil, memberIds: [String] = [], createdAt: Date = Date(), updatedAt: Date = Date(), isShared: Bool = false) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.themeName = themeName
        self.themeColorData = themeColorData
        self.budget = budget
        self.memberIds = memberIds
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isShared = isShared
    }

    // テーマカラーを取得するComputed Property
    var themeColor: Color {
        get {
            if let colorData = themeColorData,
               let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
                return Color(uiColor)
            }
            // デフォルトカラー
            return Color.orange
        }
        set {
            let uiColor = UIColor(newValue)
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: true)
                self.themeColorData = data
            } catch {
                print("Error saving color data: \(error)")
            }
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
        schedules?.forEach { schedule in
            schedule.items?.forEach { item in
                if let cost = item.cost {
                    totalCost += cost
                }
            }
        }

        return (totalCost / totalBudget) * 100
    }
}

