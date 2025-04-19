//  ポップなデザインのカスタムボタン
//  PopButton.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI

// MARK: - 透かしガラス風ボタンのスタイルを定義

struct GlassButtonStyle: ButtonStyle {
    // ボタンの色を外部から指定できるようにプロパティを追加
    var accentColor: Color = .blue // ガラスの縁や文字の色 (変更可能)
    var foregroundColor: Color = .white // 文字色
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .foregroundColor(foregroundColor)
            .background(
                ZStack {
                    // ぼかしレイヤー
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.15))
                        .blur(radius: 3)
                    
                    // 半透明のガラス効果
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.2))
                    
                    // 上部に光沢効果
                    RoundedRectangle(cornerRadius: 15)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1)
                                ]),
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                    
                    // 縁取り
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(accentColor.opacity(0.8), lineWidth: 1.5)
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 15))
            // 内側と外側の影を組み合わせてガラス感を強調
            .shadow(color: accentColor.opacity(0.3), radius: 5, x: 0, y: 3)
            .shadow(color: Color.white.opacity(0.3), radius: 2, x: 0, y: -1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0), value: configuration.isPressed)
    }
}

// MARK: - GlassButtonStyle を適用したボタン (使いやすくするためのラッパー)

struct GlassButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: Label
    var color: Color = .blue // ボタンのアクセントカラーをカスタマイズ可能
    var textColor: Color = .white // 文字色をカスタマイズ可能

    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(GlassButtonStyle(accentColor: color, foregroundColor: color))
    }
}

// MARK: - プレビュー

#Preview {
    // 背景に何かコンテンツを置いて、透け具合を確認する
    ZStack {
//        // 背景用のグラデーション
//        LinearGradient(
//            gradient: Gradient(colors: [Color.orange, Color.purple]),
//            startPoint: .topLeading,
//            endPoint: .bottomTrailing
//        )
//        .ignoresSafeArea() // 画面全体に広げる

        // 背景用の画像 (もしあれば)
        /*
        Image("backgroundImage") // ← 好きな画像名に置き換えてください
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .opacity(0.7)
         */

        // ボタンを配置
        VStack(spacing: 30) {
            GlassButton(action: {
                print("ガラスボタン1 タップ！")
            }, label: {
                Text("ガラスボタン (青縁)")
            }, color: .blue) // 縁の色を指定
            
            GlassButton(action: {
                print("ボタンがタップされました")
            }) {
                Text("ガラスボタン")
            }

            // 色をカスタマイズした例
            GlassButton(action: {
                print("赤いボタンがタップされました")
            }, label: {
                HStack {
                    Image(systemName: "heart.fill")
                    Text("いいね！")
                }
            }, color: .red)

            GlassButton(action: {
                print("ガラスボタン2 タップ！")
            }, label: {
                HStack {
                    Image(systemName: "star.fill")
                    Text("お気に入り (ピンク縁)")
                }
            }, color: .pink) // 文字色も縁に合わせる例

            GlassButton(action: {
                print("ガラスボタン3 タップ！")
            }, label: {
                Text("緑縁ボタン")
            }, color: .green) // 緑縁

            GlassButton(action: {
                print("ガラスボタン4 タップ！")
            }, label: {
                Image(systemName: "trash")
            }, color: .red) // アイコンのみ
                .padding(5)
        }
        .padding()
    }
}
