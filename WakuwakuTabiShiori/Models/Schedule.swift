//  日程データ (@Model)
//  Schedule.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftData
import SwiftUI

@Model
final class Schedule {
    var date: Date
    var title: String?
    @Relationship(deleteRule: .cascade, inverse: \PlanItem.schedule)
    var items: [PlanItem] = []
    var plan: Plan
    var notes: String?
    var createdAt: Date
    var updatedAt: Date

    init(
        date: Date = Date(),
        title: String? = nil,
        notes: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        plan: Plan
    ) {
        self.date = date
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.plan = plan
    }

    // その日の総コストを計算
    var totalCost: Double {
        return items.reduce(0) { result, item in
            result + (item.cost ?? 0)
        }
    }

    // 日程内の項目を時間順でソートして取得
    var sortedItems: [PlanItem] {
        return items.sorted(by: { $0.time < $1.time })
    }
}
