import Foundation

// MARK: - Notification Repository Protocol
protocol NotificationRepositoryProtocol {
    func fetchNotifications() async throws -> [AppNotification]
    func markAsRead(id: String) async throws
    func markAllAsRead() async throws
}

// MARK: - Mock Notification Repository
class MockNotificationRepository: NotificationRepositoryProtocol {
    private var notifications: [AppNotification] = AppNotification.mockNotifications

    func fetchNotifications() async throws -> [AppNotification] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return notifications
    }

    func markAsRead(id: String) async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        if let index = notifications.firstIndex(where: { $0.id == id }) {
            notifications[index].isRead = true
        }
    }

    func markAllAsRead() async throws {
        try await Task.sleep(nanoseconds: 100_000_000)
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
}
