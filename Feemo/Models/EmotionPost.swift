import Foundation

struct EmotionPost: Identifiable, Codable {
    let id: String
    let userId: String
    let groupId: String?
    let emotionPrimary: String
    let emotionSecondary: String?
    let intensity: Int
    let shortNote: String?
    let visibilityScope: VisibilityScope
    let createdAt: Date
    let expiresAt: Date?
    var reactions: [PostReaction]
    var authorNickname: String
    var authorIconColor: String

    var emotion: EmotionType? {
        EmotionType(rawValue: emotionPrimary)
    }
}

struct PostReaction: Identifiable, Codable {
    let id: String
    let postId: String
    let reactorUserId: String
    let reactionType: ReactionType
    let createdAt: Date
}

extension EmotionPost {
    func reactionCount(for type: ReactionType) -> Int {
        reactions.filter { $0.reactionType == type }.count
    }

    func hasReacted(userId: String, reactionType: ReactionType) -> Bool {
        reactions.contains { $0.reactorUserId == userId && $0.reactionType == reactionType }
    }
}

// MARK: - Mock Data
extension EmotionPost {
    static let mockPosts: [EmotionPost] = [
        EmotionPost(
            id: "1",
            userId: "u2",
            groupId: nil,
            emotionPrimary: EmotionType.calm.rawValue,
            emotionSecondary: nil,
            intensity: 3,
            shortNote: "ゆっくりした朝",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-600),
            expiresAt: nil,
            reactions: [],
            authorNickname: "みお",
            authorIconColor: "A8C8E8"
        ),
        EmotionPost(
            id: "2",
            userId: "u3",
            groupId: nil,
            emotionPrimary: EmotionType.overwhelmed.rawValue,
            emotionSecondary: nil,
            intensity: 4,
            shortNote: nil,
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-1800),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r1", postId: "2", reactorUserId: "u1", reactionType: .gyu, createdAt: Date())
            ],
            authorNickname: "りく",
            authorIconColor: "E8A0A0"
        ),
        EmotionPost(
            id: "3",
            userId: "u4",
            groupId: nil,
            emotionPrimary: EmotionType.happy.rawValue,
            emotionSecondary: nil,
            intensity: 5,
            shortNote: "テスト終わった！！",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-3600),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r2", postId: "3", reactorUserId: "u2", reactionType: .ureshii, createdAt: Date()),
                PostReaction(id: "r3", postId: "3", reactorUserId: "u3", reactionType: .erai, createdAt: Date())
            ],
            authorNickname: "はるか",
            authorIconColor: "F9C784"
        ),
        EmotionPost(
            id: "4",
            userId: "u5",
            groupId: nil,
            emotionPrimary: EmotionType.sleepy.rawValue,
            emotionSecondary: nil,
            intensity: 2,
            shortNote: nil,
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-7200),
            expiresAt: nil,
            reactions: [],
            authorNickname: "そうた",
            authorIconColor: "C3B1D8"
        ),
        EmotionPost(
            id: "5",
            userId: "u6",
            groupId: nil,
            emotionPrimary: EmotionType.lonely.rawValue,
            emotionSecondary: nil,
            intensity: 3,
            shortNote: "誰かと話したい",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-10800),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r4", postId: "5", reactorUserId: "u1", reactionType: .mimamoru, createdAt: Date())
            ],
            authorNickname: "ゆい",
            authorIconColor: "9EB8D8"
        )
    ]
}
