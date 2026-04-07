import Foundation

struct AppNotification: Identifiable, Codable {
    let id: String
    let userId: String
    let type: NotificationType
    let title: String
    let body: String
    let relatedPostId: String?
    let relatedGroupId: String?
    var isRead: Bool
    let createdAt: Date

    enum NotificationType: String, Codable {
        case reaction = "reaction"
        case groupInvite = "group_invite"
        case syncTime = "sync_time"
    }
}

extension AppNotification {
    static let mockNotifications: [AppNotification] = [
        AppNotification(
            id: "n1",
            userId: "u1",
            type: .reaction,
            title: "みおがリアクションしました",
            body: "「ぎゅ」をもらいました",
            relatedPostId: "1",
            relatedGroupId: nil,
            isRead: false,
            createdAt: Date().addingTimeInterval(-300)
        ),
        AppNotification(
            id: "n2",
            userId: "u1",
            type: .reaction,
            title: "りくがリアクションしました",
            body: "「わかる」をもらいました",
            relatedPostId: "1",
            relatedGroupId: nil,
            isRead: false,
            createdAt: Date().addingTimeInterval(-1200)
        ),
        AppNotification(
            id: "n3",
            userId: "u1",
            type: .syncTime,
            title: "いまの気分、置いてって",
            body: "今の感情をひと粒だけ残そう",
            relatedPostId: nil,
            relatedGroupId: nil,
            isRead: true,
            createdAt: Date().addingTimeInterval(-7200)
        )
    ]
}
