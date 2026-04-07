import Foundation

// MARK: - User DTOs
struct UserDTO: Decodable {
    let id: String
    let nickname: String
    let iconColor: String
    let createdAt: String

    func toFeemoUser() -> FeemoUser {
        FeemoUser(
            id: id,
            nickname: nickname,
            iconColor: iconColor,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date()
        )
    }
}

struct UpdateNicknameResponse: Decodable {
    let user: UserDTO
}

struct WeeklySummaryResponse: Decodable {
    let postCount: Int
    let topEmotions: [String]
    let moodScore: Int?
}

// MARK: - Live Profile Repository
class LiveProfileRepository: ProfileRepositoryProtocol {
    private let client = APIClient.shared

    func fetchMoodLog(cursor: String?) async throws -> [EmotionPost] {
        var path = "/me/mood-log"
        if let cursor { path += "?cursor=\(cursor.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cursor)" }
        let response: FeedResponse = try await client.get(path: path)
        return response.posts.map { $0.toEmotionPost() }
    }

    func fetchWeeklySummary() async throws -> WeeklySummary {
        let response: WeeklySummaryResponse = try await client.get(path: "/me/mood-summary/week")
        return WeeklySummary(
            postCount: response.postCount,
            topEmotions: response.topEmotions,
            moodScore: response.moodScore
        )
    }

    func updateNickname(_ nickname: String) async throws -> FeemoUser {
        struct Body: Encodable { let nickname: String }
        let response: UpdateNicknameResponse = try await client.patch(
            path: "/me/nickname",
            body: Body(nickname: nickname)
        )
        return response.user.toFeemoUser()
    }

    func registerDeviceToken(_ token: String) async throws {
        struct Body: Encodable { let apnsToken: String }
        let _: EmptyResponse = try await client.post(
            path: "/devices/register",
            body: Body(apnsToken: token)
        )
    }
}
