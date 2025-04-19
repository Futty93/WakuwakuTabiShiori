//  場所・予定の追加・編集画面
//  PlanItemEditView.swift
//  WakuwakuTabiShiori
//
//  Created by 二渡和輝 on 2025/04/19.
//

import SwiftUI
import SwiftData
import PhotosUI

struct PlanItemEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    // 編集中のアイテム（新規作成時はnil）
    var item: PlanItem?
    // 所属する日程
    let schedule: Schedule
    // 親の旅行プラン
    let plan: Plan?

    // フォーム入力状態
    @State private var name = ""
    @State private var memo = ""
    @State private var time = Date()
    @State private var category = "other"
    @State private var cost: Double?
    @State private var address = ""
    @State private var isCompleted = false

    // 写真関連
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var uiImage: UIImage?

    // 位置情報（将来的にMKMapViewと連携）
    @State private var latitude: Double?
    @State private var longitude: Double?

    // カテゴリー選択肢
    let categories = [
        ("transport", "交通", "bus.fill"),
        ("meal", "食事", "fork.knife"),
        ("sightseeing", "観光", "camera.fill"),
        ("hotel", "宿泊", "bed.double.fill"),
        ("activity", "アクティビティ", "figure.walk"),
        ("shopping", "ショッピング", "cart.fill"),
        ("other", "その他", "mappin")
    ]

    // カテゴリーに基づく色の取得
    private var categoryColor: Color {
        switch category {
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
        Form {
            // 基本情報セクション
            Section {
                TextField("名称（必須）", text: $name)
                    .font(.headline)

                DatePicker("時間", selection: $time, displayedComponents: [.hourAndMinute, .date])

                // カテゴリー選択
                HStack {
                    Text("カテゴリー")
                    Spacer()
                    Menu {
                        ForEach(categories, id: \.0) { code, title, icon in
                            Button {
                                self.category = code
                            } label: {
                                Label(title, systemImage: icon)
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: getCategoryIcon(for: category))
                                .foregroundColor(categoryColor)
                            Text(getCategoryName(for: category))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            } header: {
                Text("基本情報")
                    .foregroundColor(plan?.themeColor ?? .blue)
            }

            // メモと住所
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text("メモ（任意）")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    TextEditor(text: $memo)
                        .frame(minHeight: 100)
                }
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))

                HStack {
                    Image(systemName: "mappin")
                        .foregroundColor(.red)
                    TextField("住所", text: $address)
                }
            }

            // 写真セクション
            Section {
                VStack(alignment: .leading) {
                    if let uiImage = uiImage {
                        HStack {
                            Spacer()
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 200)
                                .cornerRadius(8)
                            Spacer()
                        }

                        // 写真削除ボタン
                        Button(role: .destructive) {
                            self.uiImage = nil
                            self.photoData = nil
                        } label: {
                            Label("写真を削除", systemImage: "trash")
                        }
                        .padding(.top, 8)
                    }

                    // 写真選択ボタン
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label("写真を追加", systemImage: "photo")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(categoryColor)
                    .onChange(of: photoItem) { oldValue, newValue in
                        Task {
                            if let data = try? await newValue?.loadTransferable(type: Data.self) {
                                photoData = data
                                uiImage = UIImage(data: data)
                            }
                        }
                    }
                }
            } header: {
                Text("写真")
                    .foregroundColor(plan?.themeColor ?? .blue)
            }

            // 予算セクション
            Section {
                HStack {
                    Text("¥")
                    TextField("費用（任意）", value: $cost, format: .number)
                        .keyboardType(.numberPad)
                }

                Toggle("完了済み", isOn: $isCompleted)
            } header: {
                Text("費用・状態")
                    .foregroundColor(plan?.themeColor ?? .blue)
            }

            // 保存ボタン
            Section {
                Button {
                    saveItem()
                } label: {
                    Text("保存")
                        .bold()
                        .frame(maxWidth: .infinity)
                }
                .listRowBackground(name.isEmpty ? Color.gray.opacity(0.3) : plan?.themeColor ?? .blue)
                .foregroundColor(.white)
                .disabled(name.isEmpty)
            }
            .listRowInsets(EdgeInsets())
        }
        .navigationTitle(item == nil ? "新規予定" : "予定を編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("キャンセル") {
                    dismiss()
                }
            }
        }
        .onAppear {
            // 既存アイテムの場合は値を設定
            if let item = item {
                name = item.name
                time = item.time
                category = item.category
                memo = item.memo ?? ""
                cost = item.cost
                address = item.address ?? ""
                isCompleted = item.isCompleted
                photoData = item.photoData
                uiImage = item.photo
                latitude = item.latitude
                longitude = item.longitude
            } else {
                // 新規作成の場合は選択中の日付にセット
                time = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: schedule.date) ?? Date()
            }
        }
    }

    // カテゴリーコードから名前を取得
    private func getCategoryName(for code: String) -> String {
        categories.first(where: { $0.0 == code })?.1 ?? "その他"
    }

    // カテゴリーコードからアイコンを取得
    private func getCategoryIcon(for code: String) -> String {
        categories.first(where: { $0.0 == code })?.2 ?? "mappin"
    }

    // アイテム保存処理
    private func saveItem() {
        if let item = item {
            // 既存アイテムの更新
            item.name = name
            item.time = time
            item.category = category
            item.memo = memo.isEmpty ? nil : memo
            item.cost = cost
            item.address = address.isEmpty ? nil : address
            item.isCompleted = isCompleted
            item.photoData = photoData
            item.latitude = latitude
            item.longitude = longitude
            item.updatedAt = Date()
        } else {
            // 新規アイテムの作成
            let newItem = PlanItem(
                time: time,
                category: category,
                name: name,
                memo: memo.isEmpty ? nil : memo,
                cost: cost,
                photoData: photoData,
                latitude: latitude,
                longitude: longitude,
                address: address.isEmpty ? nil : address,
                createdAt: Date(),
                updatedAt: Date(),
                isCompleted: isCompleted
            )

            // リレーションを設定
            newItem.schedule = schedule
            schedule.items?.append(newItem)
        }

        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Plan.self, configurations: config)

    // サンプルデータ
    let plan = Plan(title: "群馬旅行", themeName: "Default", createdAt: Date())
    let schedule = Schedule(date: Date(), title: "1日目")

    return NavigationStack {
        PlanItemEditView(schedule: schedule, plan: plan)
    }
    .modelContainer(container)
}
