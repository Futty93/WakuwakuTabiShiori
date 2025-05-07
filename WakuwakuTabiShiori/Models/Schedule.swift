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
    var title: String? // 日程のタイトル（例：「1日目：東京観光」）
    @Relationship(deleteRule: .cascade, inverse: \PlanItem.schedule)
    var items: [PlanItem]? = [] // 場所・予定リスト
    var plan: Plan? // どのPlanに属するか (逆リレーション)
    var notes: String? // その日のメモ
    var createdAt: Date // 作成日時
    var updatedAt: Date // 更新日時

    init( date: Date = Date(), title: String? = nil, notes: String? = nil, createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.date = date
        self.title = title
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    // その日の総コストを計算
    var totalCost: Double {
        return items?.reduce(0) { result, item in
            result + (item.cost ?? 0)
        } ?? 0
    }

    // 日程内の項目を時間順でソートして取得
    var sortedItems: [PlanItem] {
        return items?.sorted(by: { $0.time < $1.time }) ?? []
    }
}
