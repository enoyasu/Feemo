import Foundation

// MARK: - Notification DTOs
struct NotificationsResponse: Decodable {
    let notifications: [NotificationDTO]
}

struct NotificationDTO: Decodable {
    let id: String
    let userId: String
    let type: String
    let title: String
    let body: String
    let relatedPostId: String?
    let relatedGroupId: String?
    let isRead: Bool
    let createdAt: String

    func toAppNotification() -> AppNotification {
        AppNotification(
            id: id,
            userId: userId,
            type: AppNotification.NotificationType(rawValue: type) ?? .syncTime,
            title: title,
            body: body,
            relatedPostId: relatedPostId,
            relatedGroupId: relatedGroupId,
            isRead: isRead,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date()
        )
    }
}

// MARK: - Live Notification Repository
class LiveNotificationRepository: NotificationRepositoryProtocol {
    private let client = APIClient.shared

    func fetchNotifications() async throws -> [AppNotification] {
        let response: NotificationsResponse = try await client.get(path: "/notifications")
        return response.notifications.map { $0.toAppNotification() }
    }

    func markAsRead(id: String) async throws {
        struct Body: Encodable {}
        let _: EmptyResponse = try await client.patch(path: "/notifications/\(id)/read", body: Body())
    }

    func markAllAsRead() async throws {
        struct Body: Encodable {}
        let _: EmptyResponse = try await client.patch(path: "/notifications/read-all", body: Body())
    }
}
