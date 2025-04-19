//
//  User.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftData
import SwiftUI
import CloudKit

@Model
final class User {
    var id: String // CloudKit recordID または UUID文字列
    var name: String
    var avatarData: Data? // アバターアイコン
    var email: String?
    var lastActiveAt: Date?
    var createdAt: Date

    // 共有関連のプロパティ
    var sharedRecordID: String? // CloudKitでの共有レコードID
    var isCurrentUser: Bool = false // 現在のデバイスユーザーかどうか

    init(id: String = UUID().uuidString, name: String = "", avatarData: Data? = nil, email: String? = nil, lastActiveAt: Date? = nil, createdAt: Date = Date(), sharedRecordID: String? = nil, isCurrentUser: Bool = false) {
        self.id = id
        self.name = name
        self.avatarData = avatarData
        self.email = email
        self.lastActiveAt = lastActiveAt
        self.createdAt = createdAt
        self.sharedRecordID = sharedRecordID
        self.isCurrentUser = isCurrentUser
    }

    // アバター画像を取得
    var avatar: UIImage? {
        if let data = avatarData {
            return UIImage(data: data)
        }
        return UIImage(systemName: "person.circle.fill") // デフォルトアイコン
    }

    // CloudKitユーザー情報からUserモデルを作成するファクトリメソッド
    static func from(ckUserIdentity: CKUserIdentity?, name: String? = nil) -> User? {
        guard let userRecordID = ckUserIdentity?.userRecordID?.recordName else {
            return nil
        }

        let user = User(
            id: userRecordID,
            name: name ?? ckUserIdentity?.nameComponents?.formatted() ?? "未設定",
            isCurrentUser: false
        )

        return user
    }
}
