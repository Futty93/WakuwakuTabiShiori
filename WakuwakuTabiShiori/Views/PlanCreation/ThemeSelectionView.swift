//  テーマ選択画面
//  ThemeSelectionView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI

struct ThemeSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedThemeName: String
    @Binding var selectedColor: Color

    // テーマのサンプルデータ
    let themes: [(name: String, image: String, color: Color)] = [
        ("Default", "sparkles", .orange),
        ("Sea", "water.waves", .blue),
        ("Mountain", "mountain.2", .green),
        ("City", "building.2", .gray),
        ("Cafe", "cup.and.saucer", .brown),
        ("Festival", "music.note", .purple),
        ("Cherry Blossom", "leaf", .pink),
        ("Autumn", "leaf.fill", .orange)
    ]

    // カラーパレット
    let colorPalette: [Color] = [
        .orange, .yellow, .pink, .red, .green, .mint,
        .blue, .cyan, .indigo, .purple, .brown
    ]

    var body: some View {
        VStack(spacing: 0) {
            // テーマ選択セクション
            ScrollView {
                VStack(spacing: 24) {
                    Text("旅行テーマを選ぼう！")
                        .font(.title2.bold())
                        .padding(.top)

                    // テーマグリッド
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                        ForEach(themes, id: \.name) { theme in
                            themeCard(name: theme.name, image: theme.image, color: theme.color)
                                .padding(8)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(selectedThemeName == theme.name ?
                                             Color.gray.opacity(0.2) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(selectedThemeName == theme.name ?
                                               selectedColor : Color.clear, lineWidth: 3)
                                )
                                .onTapGesture {
                                    selectedThemeName = theme.name
                                    // テーマに基づいたデフォルトの色をセット
                                    if selectedColor == Color.orange {
                                        selectedColor = theme.color
                                    }
                                }
                        }
                    }
                    .padding(.horizontal)

                    Divider()
                        .padding(.vertical)

                    // カラーピッカーセクション
                    Text("テーマカラーをカスタマイズ")
                        .font(.headline)

                    // カラーパレット
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 12) {
                        ForEach(colorPalette, id: \.self) { color in
                            Circle()
                                .fill(color)
                                .frame(width: 44, height: 44)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: selectedColor == color ? 3 : 0)
                                )
                                .shadow(color: .black.opacity(0.15), radius: 2, x: 0, y: 1)
                                .onTapGesture {
                                    selectedColor = color
                                }
                                .padding(5)
                        }
                    }
                    .padding(.horizontal)

                    // カラーピッカー（カスタムカラー用）
                    ColorPicker("カスタムカラー", selection: $selectedColor, supportsOpacity: false)
                        .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }

            // 決定ボタン
            Button {
                dismiss()
            } label: {
                Text("決定")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedColor)
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 10)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("テーマ選択")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") {
                    dismiss()
                }
            }
        }
    }

    // テーマカードビュー
    private func themeCard(name: String, image: String, color: Color) -> some View {
        VStack(spacing: 10) {
            Image(systemName: image)
                .font(.system(size: 32))
                .foregroundColor(color)
                .frame(width: 60, height: 60)
                .background(
                    Circle()
                        .fill(color.opacity(0.15))
                )
                .padding(.top, 8)

            Text(name)
                .font(.headline)
                .foregroundColor(.primary)

            Spacer(minLength: 0)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    NavigationStack {
        ThemeSelectionView(
            selectedThemeName: .constant("Sea"),
            selectedColor: .constant(.blue)
        )
    }
}
