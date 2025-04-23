import SwiftUI
import SwiftData
import PhotosUI

// 全体的なプラン詳細用ViewModel
class PlanDetailViewModel: ObservableObject {
    @Published var plan: Plan
    var modelContext: ModelContext

    init(plan: Plan, modelContext: ModelContext) {
        self.plan = plan
        self.modelContext = modelContext
    }

    // 使用済み予算を計算
    func calculateUsedBudget() -> Double? {
        guard let schedules = plan.schedules else { return nil }

        var total: Double = 0
        for schedule in schedules {
            if let items = schedule.items {
                for item in items {
                    if let cost = item.cost {
                        total += cost
                    }
                }
            }
        }

        return total
    }

    // 予算使用率の計算
    func calculateBudgetUsagePercentage() -> Double? {
        guard let totalBudget = plan.budget, totalBudget > 0,
              let usedBudget = calculateUsedBudget() else { return nil }

        return (usedBudget / totalBudget) * 100
    }

    // 残り予算の計算
    func calculateRemainingBudget() -> Double? {
        guard let totalBudget = plan.budget,
              let usedBudget = calculateUsedBudget() else { return nil }

        return totalBudget - usedBudget
    }
}

// プラン項目の操作用ViewModel
class PlanItemViewModel: ObservableObject {
    @Published var item: PlanItem
    var modelContext: ModelContext

    init(item: PlanItem, modelContext: ModelContext) {
        self.item = item
        self.modelContext = modelContext
    }

    // 項目の削除
    func deleteItem() {
        modelContext.delete(item)

        do {
            try modelContext.save()
            // UIの更新を通知
            NotificationCenter.default.post(name: Notification.Name("PlanDataChanged"), object: nil)
            print("Item Deleted: \(item.name)")
        } catch {
            print("Error deleting item: \(error)")
        }
    }
}

// プラン項目の編集用ViewModel
class PlanItemEditViewModel: ObservableObject {
    // フォーム入力状態
    @Published var name = ""
    @Published var memo = ""
    @Published var time = Date()
    @Published var category = "other"
    @Published var cost: Double?
    @Published var address = ""
    @Published var isCompleted = false

    // 写真関連
    @Published var photoItem: PhotosPickerItem?
    @Published var photoData: Data?
    @Published var uiImage: UIImage?

    // 位置情報
    @Published var latitude: Double?
    @Published var longitude: Double?

    var modelContext: ModelContext
    private var item: PlanItem?
    private var schedule: Schedule
    private var plan: Plan?
    var dismissAction: DismissAction?

    init(modelContext: ModelContext, item: PlanItem? = nil, schedule: Schedule, plan: Plan?, dismiss: DismissAction? = nil) {
        self.modelContext = modelContext
        self.item = item
        self.schedule = schedule
        self.plan = plan
        self.dismissAction = dismiss

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

    // 入力バリデーション
    var isFormValid: Bool {
        !name.isEmpty
    }

    // カテゴリーに基づく色の取得
    var categoryColor: Color {
        Color.fromCategory(category)
    }

    // 画像のロード処理
    func loadImage(from photoItem: PhotosPickerItem) async {
        do {
            if let data = try await photoItem.loadTransferable(type: Data.self) {
                DispatchQueue.main.async {
                    self.photoData = data
                    self.uiImage = UIImage(data: data)
                }
            }
        } catch {
            print("Error loading image: \(error)")
        }
    }

    // アイテム保存処理
    func saveItem() {
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

            print("Item Updated: \(item.name)")
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

            print("New Item Created: \(newItem.name)")
        }

        // データを保存
        do {
            try modelContext.save()
            // UIの更新を通知
            NotificationCenter.default.post(name: Notification.Name("PlanDataChanged"), object: nil)
        } catch {
            print("Error saving item: \(error)")
        }

        dismissAction?()
    }
}
