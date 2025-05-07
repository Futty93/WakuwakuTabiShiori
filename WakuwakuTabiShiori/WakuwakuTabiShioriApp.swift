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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            PlanItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            // ここに最初に表示するビューを指定（現状PlanCreateViewを表示）
            TopView()
                .environment(\.colorScheme, .light) // 常にライトモードで表示
        }
        .modelContainer(sharedModelContainer)
    }
}
