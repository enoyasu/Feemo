import Foundation

struct FeemoGroup: Identifiable, Codable {
    let id: String
    var name: String
    let ownerUserId: String
    var memberCount: Int
    var latestPostAt: Date?
    var latestEmotion: String?
    let createdAt: Date
}

extension FeemoGroup {
    static let mockGroups: [FeemoGroup] = [
        FeemoGroup(
            id: "g1",
            name: "大学の友達",
            ownerUserId: "u1",
            memberCount: 5,
            latestPostAt: Date().addingTimeInterval(-600),
            latestEmotion: EmotionType.calm.rawValue,
            createdAt: Date().addingTimeInterval(-86400 * 30)
        ),
        FeemoGroup(
            id: "g2",
            name: "高校クラス",
            ownerUserId: "u2",
            memberCount: 8,
            latestPostAt: Date().addingTimeInterval(-3600),
            latestEmotion: EmotionType.happy.rawValue,
            createdAt: Date().addingTimeInterval(-86400 * 60)
        )
    ]
}
