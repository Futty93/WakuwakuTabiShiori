//  場所・予定項目のデータ (@Model)
//  PlanItem.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftData
import SwiftUI

@Model
final class PlanItem {
    var id: UUID
    var time: Date
    var category: String // 例: "transport", "meal", "sightseeing"
    var name: String
    var memo: String?
    var cost: Double?
    // var photoData: Data? // 写真データ (Data型で保持 or ファイルパスを保持)
    var schedule: Schedule? // どのScheduleに属するか

    init(id: UUID = UUID(), time: Date = Date(), category: String = "other", name: String = "", memo: String? = nil, cost: Double? = nil) {
        self.id = id
        self.time = time
        self.category = category
        self.name = name
        self.memo = memo
        self.cost = cost
    }
}
