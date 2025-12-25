//  SwiftDataのモデルコンテキスト関連のヘルパー
//  ModelContextHelpers.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/06/09.
//

import SwiftUI
import SwiftData

// MARK: - ModelContext ヘルパー

extension ModelContext {
    // 変更を保存して成功・失敗を返す
    func saveChanges() -> Bool {
        do {
            try save()
            return true
        } catch {
            print("Error saving to model context: \(error)")
            return false
        }
    }

    // モデルの削除と保存を一度に行う
    func deleteAndSave<T: PersistentModel>(_ model: T) -> Bool {
        delete(model)
        return saveChanges()
    }
}

// MARK: - ビューモデルのためのプロトコル

// ModelContextを扱うViewModelのための共通プロトコル
protocol ModelContextProvider: ObservableObject {
    var modelContext: ModelContext { get set }

    // 環境から取得したModelContextに置き換える
    func updateModelContext(_ newContext: ModelContext)
}

extension ModelContextProvider {
    // デフォルト実装
    func updateModelContext(_ newContext: ModelContext) {
        self.modelContext = newContext
    }
}

// MARK: - SwiftUI用拡張

// 一時的なModelContextを作成するためのヘルパー関数
func createTemporaryModelContext<T: PersistentModel>(_ modelType: T.Type) -> ModelContext {
    let temporaryContainer = try! ModelContainer(for: modelType, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    return ModelContext(temporaryContainer)
}
