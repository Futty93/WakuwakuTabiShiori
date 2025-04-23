//
//  WakuwakuTabiShioriApp.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

@main
struct WakuwakuTabiShioriApp: App {
    // SwiftDataモデルコンテナの生成
    let modelContainer: ModelContainer

    init() {
        do {
            // 本番用の設定
            let schema = Schema([Plan.self, Schedule.self, PlanItem.self])

            // CloudKitとの統合を準備（将来の拡張用）
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .automatic // 将来的にCloudKitと統合する準備
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            print("SwiftData model container initialized successfully")
        } catch {
            // 初期化に失敗した場合のフォールバック
            print("Failed to initialize SwiftData model container: \(error)")
            fatalError("Failed to initialize SwiftData model container")
        }
    }

    var body: some Scene {
        WindowGroup {
            // ここに最初に表示するビューを指定（現状PlanCreateViewを表示）
            TopView()
                .environment(\.colorScheme, .light) // 常にライトモードで表示
        }
        .modelContainer(modelContainer)
    }
}
