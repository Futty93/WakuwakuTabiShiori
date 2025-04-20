//  テーマカラー定義や取得処理
//  Color+Themes.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import UIKit

// MARK: - Color拡張
extension Color {
    // MARK: - テーマ関連

    // テーマプリセット - 名前、アイコン名、色の対応
    static let themePresets: [(name: String, icon: String, color: Color)] = [
        ("Default", "sparkles", .orange),
        ("Sea", "water.waves", .blue),
        ("Mountain", "mountain.2", .green),
        ("City", "building.2", .gray),
        ("Cafe", "cup.and.saucer", .brown),
        ("Festival", "music.note", .purple),
        ("Cherry Blossom", "leaf", .pink),
        ("Autumn", "leaf.fill", .orange)
    ]

    // テーマ名から色を取得
    static func fromThemeName(_ themeName: String) -> Color {
        themePresets.first(where: { $0.name == themeName })?.color ?? .orange
    }

    // テーマ名からアイコン名を取得
    static func iconNameForTheme(_ themeName: String) -> String {
        themePresets.first(where: { $0.name == themeName })?.icon ?? "sparkles"
    }

    // ビタミンカラーパレット - ポップでビタミンカラーの配列
    static let vitaminColors: [Color] = [
        .orange, .yellow, .pink, .red, .green, .mint,
        .blue, .cyan, .indigo, .purple, .brown
    ]

    // ランダムビタミンカラー
    static func randomVitaminColor() -> Color {
        vitaminColors.randomElement() ?? .orange
    }

    // MARK: - カテゴリー関連

    // カテゴリーコードから色を取得
    static func fromCategory(_ category: String) -> Color {
        switch category {
        case "transport": return .blue
        case "meal": return .orange
        case "sightseeing": return .green
        case "hotel": return .purple
        case "activity": return .pink
        case "shopping": return .red
        default: return .gray
        }
    }

    // カテゴリー定義 - コード、表示名、アイコン名
    static let categoryDefinitions: [(code: String, name: String, icon: String)] = [
        ("transport", "交通", "bus.fill"),
        ("meal", "食事", "fork.knife"),
        ("sightseeing", "観光", "camera.fill"),
        ("hotel", "宿泊", "bed.double.fill"),
        ("activity", "アクティビティ", "figure.walk"),
        ("shopping", "ショッピング", "cart.fill"),
        ("other", "その他", "mappin")
    ]

    // カテゴリーコードから表示名を取得
    static func nameForCategory(_ code: String) -> String {
        categoryDefinitions.first(where: { $0.code == code })?.name ?? "その他"
    }

    // カテゴリーコードからアイコン名を取得
    static func iconForCategory(_ code: String) -> String {
        categoryDefinitions.first(where: { $0.code == code })?.icon ?? "mappin"
    }

    // MARK: - UIColor変換

    // UIColorからDataに変換
    static func dataFromUIColor(_ uiColor: UIColor) -> Data? {
        do {
            return try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: true)
        } catch {
            print("Error converting UIColor to Data: \(error)")
            return nil
        }
    }

    // DataからUIColorに変換
    static func uiColorFromData(_ data: Data) -> UIColor? {
        do {
            return try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data)
        } catch {
            print("Error converting Data to UIColor: \(error)")
            return nil
        }
    }

    // SwiftUI ColorからDataに変換
    func toData() -> Data? {
        Color.dataFromUIColor(UIColor(self))
    }

    // DataからSwiftUI Colorに変換
    static func fromData(_ data: Data?) -> Color {
        if let data = data, let uiColor = uiColorFromData(data) {
            return Color(uiColor)
        }
        return .orange // デフォルト色
    }
}
