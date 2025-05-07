//  場所・予定項目のデータ (@Model)
//  PlanItem.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftData
import SwiftUI
import CoreLocation
import UIKit

@Model
final class PlanItem {
    var time: Date
    var category: String // 例: "transport", "meal", "sightseeing"
    var name: String
    var memo: String?
    var cost: Double?
    var photoData: Data? // 写真データ (Data型で保持)
    var latitude: Double? // 位置情報
    var longitude: Double?
    var address: String? // 住所
    var url: URL? // 関連URL（店舗サイト、予約サイトなど）
    var schedule: Schedule? // どのScheduleに属するか
    var createdAt: Date
    var updatedAt: Date
    var isCompleted: Bool = false // タスク完了フラグ（やることリスト用）

    init(time: Date = Date(), category: String = "other", name: String = "", memo: String? = nil, cost: Double? = nil, photoData: Data? = nil, latitude: Double? = nil, longitude: Double? = nil, address: String? = nil, url: URL? = nil, createdAt: Date = Date(), updatedAt: Date = Date(), isCompleted: Bool = false) {
        self.time = time
        self.category = category
        self.name = name
        self.memo = memo
        self.cost = cost
        self.photoData = photoData
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.url = url
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isCompleted = isCompleted
    }

    // カテゴリに基づいたアイコン名を返す
    var categoryIcon: String {
        switch category {
        case "transport": return "bus.fill"
        case "meal": return "fork.knife"
        case "sightseeing": return "camera.fill"
        case "hotel": return "bed.double.fill"
        case "activity": return "figure.walk"
        case "shopping": return "cart.fill"
        default: return "mappin"
        }
    }

    // photoDataから変換したUIImageを返す計算プロパティ
    var photo: UIImage? {
        if let photoData = photoData {
            return UIImage(data: photoData)
        }
        return nil
    }

    // 位置情報をCLLocationCoordinate2Dに変換
    var coordinate: CLLocationCoordinate2D? {
        if let lat = latitude, let lon = longitude {
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return nil
    }
}
