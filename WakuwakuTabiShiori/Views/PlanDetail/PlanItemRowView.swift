//  日程内の各「場所・予定」行のビュー
//  PlanItemRowView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData

struct PlanItemRowView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var item: PlanItem
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    // 時間フォーマッター
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()

    // 通貨フォーマッター
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "JPY"
        formatter.currencySymbol = "¥"
        return formatter
    }()

    // カテゴリーに基づく色の取得
    private var categoryColor: Color {
        switch item.category {
        case "transport": return .blue
        case "meal": return .orange
        case "sightseeing": return .green
        case "hotel": return .purple
        case "activity": return .pink
        case "shopping": return .red
        default: return .gray
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 時間表示
            HStack {
                Text(timeFormatter.string(from: item.time))
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(categoryColor.opacity(0.15))
                    )
                    .foregroundColor(categoryColor)

                Spacer()

                // 金額（あれば）
                if let cost = item.cost {
                    Text(currencyFormatter.string(from: NSNumber(value: cost)) ?? "¥0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 4)

            // メインコンテンツ
            HStack(alignment: .top, spacing: 12) {
                // カテゴリーアイコン
                ZStack {
                    Circle()
                        .fill(categoryColor.opacity(0.2))
                        .frame(width: 40, height: 40)

                    Image(systemName: item.categoryIcon)
                        .font(.system(size: 20))
                        .foregroundColor(categoryColor)
                }

                // テキスト情報
                VStack(alignment: .leading, spacing: 4) {
                    // タイトル
                    Text(item.name)
                        .font(.headline)

                    // メモ（あれば）
                    if let memo = item.memo, !memo.isEmpty {
                        Text(memo)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }

                    // 住所（あれば）
                    if let address = item.address, !address.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                            Text(address)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // 写真サムネイル（あれば）
                if let photo = item.photo {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            showingEditSheet = true
        }
        .contextMenu {
            Button {
                showingEditSheet = true
            } label: {
                Label("編集", systemImage: "pencil")
            }

            Button(role: .destructive) {
                showingDeleteAlert = true
            } label: {
                Label("削除", systemImage: "trash")
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let schedule = item.schedule {
                NavigationStack {
                    PlanItemEditView(item: item, schedule: schedule, plan: schedule.plan)
                }
            }
        }
        .alert("予定を削除", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                deleteItem()
            }
        } message: {
            Text("この予定を削除してもよろしいですか？")
        }
    }

    // 項目の削除
    private func deleteItem() {
        modelContext.delete(item)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Plan.self, configurations: config)

    // サンプルデータ作成
    let item = PlanItem(
        time: Date(),
        category: "meal",
        name: "群馬名物 水沢うどん",
        memo: "有名なうどん店。予約しておくとスムーズ。",
        cost: 1500
    )

    return PlanItemRowView(item: item)
        .padding()
        .modelContainer(container)
}
