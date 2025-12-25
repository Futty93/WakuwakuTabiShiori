//  通貨表示用の共通フォーマッタ
//  NumberFormatter+Extensions.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/06/09.
//

import Foundation

extension NumberFormatter {
    // 日本円用の通貨フォーマッター
    static var japaneseYenFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.currencySymbol = "¥"
        return formatter
    }
}

// 数値関連のヘルパー関数
extension Double {
    // 日本円としてフォーマット
    func formatAsYen() -> String {
        return NumberFormatter.japaneseYenFormatter.string(from: NSNumber(value: self)) ?? "¥0"
    }
}

extension Optional where Wrapped == Double {
    // Optional Doubleを日本円としてフォーマット（nilの場合は¥0を返す）
    func formatAsYen() -> String {
        guard let value = self else { return "¥0" }
        return NumberFormatter.japaneseYenFormatter.string(from: NSNumber(value: value)) ?? "¥0"
    }
}
