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
    var themeName: String
    var themeColorData: Data?
    var budget: Double?
    var memo: String?
    var timeZoneIdentifier: String
    @Relationship(deleteRule: .cascade, inverse: \Schedule.plan)
    var schedules: [Schedule] = []
    var createdAt: Date
    var updatedAt: Date

    init(
        title: String = "",
        startDate: Date = Date(),
        endDate: Date = Date(),
        themeName: String = "Default",
        themeColorData: Data? = nil,
        budget: Double? = nil,
        memo: String? = nil,
        timeZoneIdentifier: String = "Asia/Tokyo",
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.themeName = themeName
        self.themeColorData = themeColorData
        self.budget = budget
        self.memo = memo
        self.timeZoneIdentifier = timeZoneIdentifier
        self.createdAt = createdAt
        self.updatedAt = updatedAt
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
            schedule.items.forEach { item in
                if let cost = item.cost {
                    totalCost += cost
                }
            }
        }

        return (totalCost / totalBudget) * 100
    }
}
