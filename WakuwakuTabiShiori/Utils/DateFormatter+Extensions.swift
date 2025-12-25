//  日付表示用の共通フォーマッタ
//  DateFormatter+Extensions.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import Foundation

extension DateFormatter {
    // 日付のみのフォーマッター（ロング形式） 例: "2025年5月7日"
    static var longDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    // 日付のみのフォーマッター（ミディアム形式） 例: "2025/05/07"
    static var mediumDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    // 時刻のみのフォーマッター 例: "14:30"
    static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    // 日時両方のフォーマッター 例: "2025/05/07 14:30"
    static var dateTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    // 日付（曜日あり）のフォーマッター "M/d (E)" 例: "5/7 (水)"
    static var dayWithWeekdayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d (E)"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter
    }

    // 時間のみのフォーマッター "HH:mm" 例: "14:30"
    static var hourMinuteFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

// 日付関連のヘルパー関数
extension Date {
    // 日付を文字列にフォーマット（ロング形式）
    func formatLongDate() -> String {
        return DateFormatter.longDateFormatter.string(from: self)
    }

    // 日付を文字列にフォーマット（ミディアム形式）
    func formatMediumDate() -> String {
        return DateFormatter.mediumDateFormatter.string(from: self)
    }

    // 時刻を文字列にフォーマット
    func formatTime() -> String {
        return DateFormatter.timeFormatter.string(from: self)
    }

    // 日時を文字列にフォーマット
    func formatDateTime() -> String {
        return DateFormatter.dateTimeFormatter.string(from: self)
    }

    // 日付（曜日あり）を文字列にフォーマット
    func formatDayWithWeekday() -> String {
        return DateFormatter.dayWithWeekdayFormatter.string(from: self)
    }

    // 時間のみを文字列にフォーマット
    func formatHourMinute() -> String {
        return DateFormatter.hourMinuteFormatter.string(from: self)
    }
}
