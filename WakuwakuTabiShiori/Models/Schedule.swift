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
    var id: UUID
    var date: Date
    @Relationship(deleteRule: .cascade) var items: [PlanItem]? = [] // 場所・予定リスト
    var plan: Plan? // どのPlanに属するか (逆リレーション)

    init(id: UUID = UUID(), date: Date = Date()) {
        self.id = id
        self.date = date
    }
}
