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
        // 0: ゆうな（自分）— 回復中 (intensity 3) ※ フィードに自分の投稿を表示する
        EmotionPost(
            id: "own_feed1",
            userId: "u1",
            groupId: nil,
            emotionPrimary: EmotionType.recovering.rawValue,
            emotionSecondary: nil,
            intensity: 3,
            shortNote: "すこしずつよくなってる",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-540),   // 9分前（はるかの直後）
            expiresAt: nil,
            reactions: [
                PostReaction(id: "or1", postId: "own_feed1", reactorUserId: "u2", reactionType: .gyu,    createdAt: Date()),
                PostReaction(id: "or2", postId: "own_feed1", reactorUserId: "u4", reactionType: .erai,   createdAt: Date()),
                PostReaction(id: "or3", postId: "own_feed1", reactorUserId: "u7", reactionType: .wakaru, createdAt: Date()),
            ],
            authorNickname: "ゆうな",
            authorIconColor: "A8D8C0"
        ),
        // 1: はるか — 満たされ (intensity 4)
        EmotionPost(
            id: "1",
            userId: "u4",
            groupId: nil,
            emotionPrimary: EmotionType.fulfilled.rawValue,
            emotionSecondary: nil,
            intensity: 4,
            shortNote: "今日のランチ最高だった",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-480),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r1a", postId: "1", reactorUserId: "u2", reactionType: .ureshii, createdAt: Date()),
                PostReaction(id: "r1b", postId: "1", reactorUserId: "u3", reactionType: .ureshii, createdAt: Date()),
                PostReaction(id: "r1c", postId: "1", reactorUserId: "u5", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r1d", postId: "1", reactorUserId: "u6", reactionType: .ureshii, createdAt: Date()),
            ],
            authorNickname: "はるか",
            authorIconColor: "F9C784"
        ),
        // 2: りく — むり (intensity 5)
        EmotionPost(
            id: "2",
            userId: "u3",
            groupId: nil,
            emotionPrimary: EmotionType.overwhelmed.rawValue,
            emotionSecondary: nil,
            intensity: 5,
            shortNote: "もう限界かもしれない",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-1200),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r2a", postId: "2", reactorUserId: "u1", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r2b", postId: "2", reactorUserId: "u4", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r2c", postId: "2", reactorUserId: "u5", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r2d", postId: "2", reactorUserId: "u6", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r2e", postId: "2", reactorUserId: "u7", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r2f", postId: "2", reactorUserId: "u8", reactionType: .mimamoru, createdAt: Date()),
            ],
            authorNickname: "りく",
            authorIconColor: "E8A0A0"
        ),
        // 3: みお — そわそわ (intensity 3)
        EmotionPost(
            id: "3",
            userId: "u2",
            groupId: nil,
            emotionPrimary: EmotionType.anxious.rawValue,
            emotionSecondary: nil,
            intensity: 3,
            shortNote: "明日の発表こわい",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-2700),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r3a", postId: "3", reactorUserId: "u1", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r3b", postId: "3", reactorUserId: "u4", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r3c", postId: "3", reactorUserId: "u5", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r3d", postId: "3", reactorUserId: "u6", reactionType: .erai, createdAt: Date()),
                PostReaction(id: "r3e", postId: "3", reactorUserId: "u7", reactionType: .erai, createdAt: Date()),
            ],
            authorNickname: "みお",
            authorIconColor: "A8C8E8"
        ),
        // 4: けんと — うれしい (intensity 5)
        EmotionPost(
            id: "4",
            userId: "u7",
            groupId: nil,
            emotionPrimary: EmotionType.happy.rawValue,
            emotionSecondary: nil,
            intensity: 5,
            shortNote: "付き合って1年記念日",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-4500),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r4a", postId: "4", reactorUserId: "u2", reactionType: .ureshii, createdAt: Date()),
                PostReaction(id: "r4b", postId: "4", reactorUserId: "u3", reactionType: .ureshii, createdAt: Date()),
                PostReaction(id: "r4c", postId: "4", reactorUserId: "u4", reactionType: .ureshii, createdAt: Date()),
                PostReaction(id: "r4d", postId: "4", reactorUserId: "u5", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r4e", postId: "4", reactorUserId: "u6", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r4f", postId: "4", reactorUserId: "u8", reactionType: .ureshii, createdAt: Date()),
            ],
            authorNickname: "けんと",
            authorIconColor: "9BC89B"
        ),
        // 5: さら — 焦り (intensity 4)
        EmotionPost(
            id: "5",
            userId: "u8",
            groupId: nil,
            emotionPrimary: EmotionType.impatient.rawValue,
            emotionSecondary: nil,
            intensity: 4,
            shortNote: "課題全然終わらない",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-6000),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r5a", postId: "5", reactorUserId: "u1", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r5b", postId: "5", reactorUserId: "u2", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r5c", postId: "5", reactorUserId: "u3", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r5d", postId: "5", reactorUserId: "u4", reactionType: .erai, createdAt: Date()),
                PostReaction(id: "r5e", postId: "5", reactorUserId: "u5", reactionType: .erai, createdAt: Date()),
                PostReaction(id: "r5f", postId: "5", reactorUserId: "u6", reactionType: .gyu, createdAt: Date()),
            ],
            authorNickname: "さら",
            authorIconColor: "F4A96A"
        ),
        // 6: なつ — 回復中 (intensity 3)
        EmotionPost(
            id: "6",
            userId: "u9",
            groupId: nil,
            emotionPrimary: EmotionType.recovering.rawValue,
            emotionSecondary: nil,
            intensity: 3,
            shortNote: "少しずつ立ち直ってる",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-8400),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r6a", postId: "6", reactorUserId: "u1", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r6b", postId: "6", reactorUserId: "u2", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r6c", postId: "6", reactorUserId: "u4", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r6d", postId: "6", reactorUserId: "u5", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r6e", postId: "6", reactorUserId: "u7", reactionType: .mimamoru, createdAt: Date()),
            ],
            authorNickname: "なつ",
            authorIconColor: "C3B1D8"
        ),
        // 7: あおい — しずか (intensity 2)
        EmotionPost(
            id: "7",
            userId: "u10",
            groupId: nil,
            emotionPrimary: EmotionType.calm.rawValue,
            emotionSecondary: nil,
            intensity: 2,
            shortNote: "雨の音きいてる",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-10200),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r7a", postId: "7", reactorUserId: "u3", reactionType: .gyu, createdAt: Date()),
                PostReaction(id: "r7b", postId: "7", reactorUserId: "u6", reactionType: .gyu, createdAt: Date()),
            ],
            authorNickname: "あおい",
            authorIconColor: "A8D8C0"
        ),
        // 8: そうた — ねむい (intensity 3)
        EmotionPost(
            id: "8",
            userId: "u5",
            groupId: nil,
            emotionPrimary: EmotionType.sleepy.rawValue,
            emotionSecondary: nil,
            intensity: 3,
            shortNote: nil,
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-12600),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r8a", postId: "8", reactorUserId: "u2", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r8b", postId: "8", reactorUserId: "u4", reactionType: .wakaru, createdAt: Date()),
            ],
            authorNickname: "そうた",
            authorIconColor: "9EB8D8"
        ),
        // 9: ゆい — 虚無 (intensity 2)
        EmotionPost(
            id: "9",
            userId: "u6",
            groupId: nil,
            emotionPrimary: EmotionType.void.rawValue,
            emotionSecondary: nil,
            intensity: 2,
            shortNote: "なんもやる気でない",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-15600),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r9a", postId: "9", reactorUserId: "u1", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r9b", postId: "9", reactorUserId: "u2", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r9c", postId: "9", reactorUserId: "u3", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r9d", postId: "9", reactorUserId: "u4", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r9e", postId: "9", reactorUserId: "u7", reactionType: .wakaru, createdAt: Date()),
                PostReaction(id: "r9f", postId: "9", reactorUserId: "u8", reactionType: .gyu, createdAt: Date()),
            ],
            authorNickname: "ゆい",
            authorIconColor: "B0B8C1"
        ),
        // 10: みお — 満たされ (intensity 5)
        EmotionPost(
            id: "10",
            userId: "u2",
            groupId: nil,
            emotionPrimary: EmotionType.fulfilled.rawValue,
            emotionSecondary: nil,
            intensity: 5,
            shortNote: "好きな音楽ずっときいてた",
            visibilityScope: .closeFriends,
            createdAt: Date().addingTimeInterval(-18000),
            expiresAt: nil,
            reactions: [
                PostReaction(id: "r10a", postId: "10", reactorUserId: "u4", reactionType: .ureshii, createdAt: Date()),
                PostReaction(id: "r10b", postId: "10", reactorUserId: "u9", reactionType: .ureshii, createdAt: Date()),
            ],
            authorNickname: "みお",
            authorIconColor: "A8C8E8"
        ),
    ]

    // Group-specific mock posts
    static let mockGroupPosts: [String: [EmotionPost]] = [
        "g1": [
            EmotionPost(
                id: "gp1", userId: "u2", groupId: "g1",
                emotionPrimary: EmotionType.anxious.rawValue, emotionSecondary: nil,
                intensity: 4, shortNote: "テスト期間つらい",
                visibilityScope: .group,
                createdAt: Date().addingTimeInterval(-900), expiresAt: nil,
                reactions: [
                    PostReaction(id: "gr1", postId: "gp1", reactorUserId: "u1", reactionType: .wakaru, createdAt: Date()),
                    PostReaction(id: "gr2", postId: "gp1", reactorUserId: "u3", reactionType: .erai, createdAt: Date()),
                ],
                authorNickname: "みお", authorIconColor: "A8C8E8"
            ),
            EmotionPost(
                id: "gp2", userId: "u3", groupId: "g1",
                emotionPrimary: EmotionType.happy.rawValue, emotionSecondary: nil,
                intensity: 5, shortNote: "単位とれた！！",
                visibilityScope: .group,
                createdAt: Date().addingTimeInterval(-5400), expiresAt: nil,
                reactions: [
                    PostReaction(id: "gr3", postId: "gp2", reactorUserId: "u1", reactionType: .ureshii, createdAt: Date()),
                    PostReaction(id: "gr4", postId: "gp2", reactorUserId: "u2", reactionType: .ureshii, createdAt: Date()),
                    PostReaction(id: "gr5", postId: "gp2", reactorUserId: "u4", reactionType: .erai, createdAt: Date()),
                ],
                authorNickname: "りく", authorIconColor: "E8A0A0"
            ),
            EmotionPost(
                id: "gp3", userId: "u4", groupId: "g1",
                emotionPrimary: EmotionType.calm.rawValue, emotionSecondary: nil,
                intensity: 3, shortNote: "図書館に引きこもり中",
                visibilityScope: .group,
                createdAt: Date().addingTimeInterval(-9000), expiresAt: nil,
                reactions: [],
                authorNickname: "はるか", authorIconColor: "F9C784"
            ),
        ],
        "g2": [
            EmotionPost(
                id: "gp4", userId: "u5", groupId: "g2",
                emotionPrimary: EmotionType.sleepy.rawValue, emotionSecondary: nil,
                intensity: 4, shortNote: "修学旅行の疲れが残ってる",
                visibilityScope: .group,
                createdAt: Date().addingTimeInterval(-2400), expiresAt: nil,
                reactions: [
                    PostReaction(id: "gr6", postId: "gp4", reactorUserId: "u1", reactionType: .wakaru, createdAt: Date()),
                ],
                authorNickname: "そうた", authorIconColor: "9EB8D8"
            ),
            EmotionPost(
                id: "gp5", userId: "u6", groupId: "g2",
                emotionPrimary: EmotionType.lonely.rawValue, emotionSecondary: nil,
                intensity: 3, shortNote: "みんないまどこにいるんだろ",
                visibilityScope: .group,
                createdAt: Date().addingTimeInterval(-7200), expiresAt: nil,
                reactions: [
                    PostReaction(id: "gr7", postId: "gp5", reactorUserId: "u1", reactionType: .gyu, createdAt: Date()),
                    PostReaction(id: "gr8", postId: "gp5", reactorUserId: "u5", reactionType: .mimamoru, createdAt: Date()),
                ],
                authorNickname: "ゆい", authorIconColor: "B0B8C1"
            ),
        ],
        "g3": [
            EmotionPost(
                id: "gp6", userId: "u8", groupId: "g3",
                emotionPrimary: EmotionType.impatient.rawValue, emotionSecondary: nil,
                intensity: 3, shortNote: "シフト入りすぎた",
                visibilityScope: .group,
                createdAt: Date().addingTimeInterval(-1800), expiresAt: nil,
                reactions: [
                    PostReaction(id: "gr9", postId: "gp6", reactorUserId: "u1", reactionType: .wakaru, createdAt: Date()),
                    PostReaction(id: "gr10", postId: "gp6", reactorUserId: "u9", reactionType: .gyu, createdAt: Date()),
                ],
                authorNickname: "さら", authorIconColor: "F4A96A"
            ),
        ],
        "g4": [
            EmotionPost(
                id: "gp7", userId: "u11", groupId: "g4",
                emotionPrimary: EmotionType.calm.rawValue, emotionSecondary: nil,
                intensity: 2, shortNote: "今日はゆっくりした",
                visibilityScope: .group,
                createdAt: Date().addingTimeInterval(-3600), expiresAt: nil,
                reactions: [
                    PostReaction(id: "gr11", postId: "gp7", reactorUserId: "u1", reactionType: .gyu, createdAt: Date()),
                ],
                authorNickname: "おかあさん", authorIconColor: "C3B1D8"
            ),
        ],
    ]
}
