//  カスタムチェックボックススタイル (リスト用など)
//  CheckboxToggleStyle.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI

// MARK: - ポップなチェックボックスのスタイルを定義

struct PopCheckboxToggleStyle: ToggleStyle {
    // チェックされた時の色をカスタマイズ可能にする
    var tintColor: Color = .pink // ポップな色

    func makeBody(configuration: Configuration) -> some View {
        // HStackでチェックボックス部分とラベルを横並びにする
        HStack(alignment: .center, spacing: 10) {
            // チェックボックス部分 (ZStackで要素を重ねる)
            ZStack {
                // 外枠 (角丸四角形)
                RoundedRectangle(cornerRadius: 6)
                    // isONがtrueならtintColorで枠を描き、falseならグレーの枠
                    .stroke(configuration.isOn ? tintColor : Color.gray.opacity(0.6), lineWidth: 2)
                    .frame(width: 24, height: 24) // サイズを指定

                // チェックマーク (isOnがtrueの時だけ表示)
                if configuration.isOn {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold)) // チェックマークのサイズと太さ
                        .foregroundColor(tintColor) // チェックマークの色
                        // アニメーションで表示/非表示
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
            }
            // ラベル部分
            configuration.label
                .foregroundColor(.primary) // ラベルの文字色

            Spacer() // 右側にスペースを空ける (レイアウト調整)
        }
        .padding(.vertical, 4) // 上下の余白を少しつける
        // HStack全体をタップ可能にして、トグル状態を切り替える
        .contentShape(Rectangle()) // タップ領域をHStack全体にする
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                configuration.isOn.toggle() // 状態を反転させる (アニメーション付き)
            }
        }
    }
}

// MARK: - プレビュー

#Preview {
    // プレビュー用に状態を保持する変数
    struct PreviewWrapper: View {
        @State private var isChecked1: Bool = false
        @State private var isChecked2: Bool = true
        @State private var isChecked3: Bool = false
        @State private var isChecked4: Bool = false

        var body: some View {
            VStack(alignment: .leading, spacing: 15) {
                Text("持ち物リスト").font(.title).bold()

                Toggle("パスポート", isOn: $isChecked1)

                Toggle("充電器", isOn: $isChecked2)

                Toggle("着替え（3日分）", isOn: $isChecked3)
                    .toggleStyle(PopCheckboxToggleStyle(tintColor: .orange)) // 色を変える例

                Toggle("おやつ", isOn: $isChecked4)
                    .toggleStyle(PopCheckboxToggleStyle(tintColor: .blue)) // 色を変える例

                Divider()

                Text("選択状態:")
                Text("パスポート: \(isChecked1 ? "✅" : "⬜️")")
                Text("充電器: \(isChecked2 ? "✅" : "⬜️")")
            }
            .padding()
            // ここでデフォルトのToggleStyleをカスタムスタイルにする
            // VStack全体に適用すれば、中のToggle全てに適用される
            .toggleStyle(PopCheckboxToggleStyle(tintColor: .pink)) // デフォルトの色を指定
        }
    }

    return PreviewWrapper()
}
