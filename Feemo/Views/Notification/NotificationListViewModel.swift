import SwiftUI

@Observable
class NotificationListViewModel {
    var notifications: [AppNotification] = []
    var isLoading = false
    var errorMessage: String? = nil

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    private let notificationRepo: any NotificationRepositoryProtocol

    init(notificationRepo: any NotificationRepositoryProtocol) {
        self.notificationRepo = notificationRepo
    }

    func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        do {
            notifications = try await notificationRepo.fetchNotifications()
        } catch {
            errorMessage = "読み込みに失敗しました"
        }
        isLoading = false
    }

    func markAsRead(id: String) async {
        do {
            try await notificationRepo.markAsRead(id: id)
            if let index = notifications.firstIndex(where: { $0.id == id }) {
                notifications[index].isRead = true
            }
        } catch { /* silent fail */ }
    }

    func markAllAsRead() async {
        do {
            try await notificationRepo.markAllAsRead()
            for index in notifications.indices {
                notifications[index].isRead = true
            }
        } catch { /* silent fail */ }
    }
}
