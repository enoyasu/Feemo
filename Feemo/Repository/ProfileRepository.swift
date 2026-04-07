import Foundation

// MARK: - Profile Repository Protocol
protocol ProfileRepositoryProtocol {
    func fetchMoodLog(cursor: String?) async throws -> [EmotionPost]
    func fetchWeeklySummary() async throws -> WeeklySummary
    func updateNickname(_ nickname: String) async throws -> FeemoUser
    func registerDeviceToken(_ token: String) async throws
}

// MARK: - Weekly Summary Model
struct WeeklySummary: Codable {
    let postCount: Int
    let topEmotions: [String]
    let moodScore: Int?
}

// MARK: - Mock Profile Repository
class MockProfileRepository: ProfileRepositoryProtocol {
    func fetchMoodLog(cursor: String?) async throws -> [EmotionPost] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return [
            EmotionPost(
                id: "mine1",
                userId: "u1",
                groupId: nil,
                emotionPrimary: EmotionType.recovering.rawValue,
                emotionSecondary: nil,
                intensity: 3,
                shortNote: "すこしずつよくなってる",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-1800),
                expiresAt: nil,
                reactions: [],
                authorNickname: "あなた",
                authorIconColor: "A8D8C0"
            ),
            EmotionPost(
                id: "mine2",
                userId: "u1",
                groupId: nil,
                emotionPrimary: EmotionType.calm.rawValue,
                emotionSecondary: nil,
                intensity: 2,
                shortNote: nil,
                visibilityScope: .private,
                createdAt: Date().addingTimeInterval(-86400),
                expiresAt: nil,
                reactions: [],
                authorNickname: "あなた",
                authorIconColor: "A8D8C0"
            ),
            EmotionPost(
                id: "mine3",
                userId: "u1",
                groupId: nil,
                emotionPrimary: EmotionType.sleepy.rawValue,
                emotionSecondary: nil,
                intensity: 4,
                shortNote: "ねむすぎてむり",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-86400 * 2),
                expiresAt: nil,
                reactions: [],
                authorNickname: "あなた",
                authorIconColor: "A8D8C0"
            ),
            EmotionPost(
                id: "mine4",
                userId: "u1",
                groupId: nil,
                emotionPrimary: EmotionType.happy.rawValue,
                emotionSecondary: nil,
                intensity: 5,
                shortNote: "最高な一日だった",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-86400 * 3),
                expiresAt: nil,
                reactions: [],
                authorNickname: "あなた",
                authorIconColor: "A8D8C0"
            ),
            EmotionPost(
                id: "mine5",
                userId: "u1",
                groupId: nil,
                emotionPrimary: EmotionType.void.rawValue,
                emotionSecondary: nil,
                intensity: 2,
                shortNote: nil,
                visibilityScope: .private,
                createdAt: Date().addingTimeInterval(-86400 * 5),
                expiresAt: nil,
                reactions: [],
                authorNickname: "あなた",
                authorIconColor: "A8D8C0"
            )
        ]
    }

    func fetchWeeklySummary() async throws -> WeeklySummary {
        try await Task.sleep(nanoseconds: 300_000_000)
        return WeeklySummary(
            postCount: 5,
            topEmotions: [EmotionType.calm.rawValue, EmotionType.recovering.rawValue, EmotionType.sleepy.rawValue],
            moodScore: nil
        )
    }

    func updateNickname(_ nickname: String) async throws -> FeemoUser {
        try await Task.sleep(nanoseconds: 400_000_000)
        return FeemoUser(
            id: "u1",
            nickname: nickname,
            iconColor: "A8D8C0",
            createdAt: Date().addingTimeInterval(-86400 * 7)
        )
    }

    func registerDeviceToken(_ token: String) async throws {
        // TODO: POST /devices/register
    }
}
