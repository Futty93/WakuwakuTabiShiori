//  様々なビュー関連の共通ヘルパー
//  ViewHelpers.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/06/09.
//

import SwiftUI
import SwiftData

// MARK: - ビューの共通拡張

extension View {
    // セクションヘッダーに色を適用するためのヘルパー関数
    func sectionHeader(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundColor(color)
            .textCase(nil)
    }

    // 標準的なカードスタイルを適用するモディファイア
    func cardStyle(cornerRadius: CGFloat = 12) -> some View {
        self.padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
            )
            .padding(.horizontal)
    }

    // 予算入力フィールド用の共通レイアウト
    func budgetInputStyle(value: Binding<Double?>) -> some View {
        HStack {
            Text("¥")
            // オプショナルな値をテキストフィールドで扱うための工夫
            let nonOptionalValue = Binding<Double>(
                get: { value.wrappedValue ?? 0 },
                set: { value.wrappedValue = $0 }
            )
            TextField("予算（任意）", value: nonOptionalValue, format: .number.precision(.fractionLength(0)))
                .keyboardType(.numberPad)
        }
    }

    // メモ入力フィールド用の共通レイアウト
    func memoInputStyle(text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("メモ（任意）")
                .font(.caption)
                .foregroundColor(.secondary)
            TextEditor(text: text)
                .frame(minHeight: 100)
                .padding(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
        }
    }
}

// NOTE: このメソッドはModelContextHelpers.swiftに移動しました
// MARK: - ModelContext関連ヘルパー

// extension View {
//     // 一時的なModelContextを作成するためのヘルパー関数
//     static func createTemporaryModelContext<T: PersistentModel>(_ modelType: T.Type) -> ModelContext {
//         let temporaryContainer = try! ModelContainer(for: modelType, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
//         return ModelContext(temporaryContainer)
//     }
// }
