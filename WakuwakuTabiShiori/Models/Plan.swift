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
    // var themeColorData: Data? // Colorを直接保存できないためDataなどに変換
    var budget: Double? // 目安予算 (任意)
    // var members: [User]? // Userモデルとのリレーションシップ
    @Relationship(deleteRule: .cascade) var schedules: [Schedule]? = [] // 日程リスト (Planが消えたらScheduleも消す)
    var createdAt: Date // 作成日時 (ソート用)

    init(id: UUID = UUID(), title: String = "", startDate: Date = Date(), endDate: Date = Date(), themeName: String = "Default", budget: Double? = nil, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.startDate = startDate
        self.endDate = endDate
        self.themeName = themeName
        self.budget = budget
        self.createdAt = createdAt
    }

    // 必要に応じてテーマカラーを取得するComputed Propertyなどを用意
    // var themeColor: Color {
    //     // themeNameに基づいてColorを返す処理
    // }
}

