import Foundation

// MARK: - Group DTOs
struct GroupsResponse: Decodable {
    let groups: [GroupDTO]
}

struct GroupDTO: Decodable {
    let id: String
    let name: String
    let ownerUserId: String
    let memberCount: Int?
    let latestPostAt: String?
    let latestEmotion: String?
    let createdAt: String

    func toFeemoGroup() -> FeemoGroup {
        FeemoGroup(
            id: id,
            name: name,
            ownerUserId: ownerUserId,
            memberCount: memberCount ?? 1,
            latestPostAt: latestPostAt.flatMap { ISO8601DateFormatter().date(from: $0) },
            latestEmotion: latestEmotion,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date()
        )
    }
}

// MARK: - Live Group Repository
class LiveGroupRepository: GroupRepositoryProtocol {
    private let client = APIClient.shared

    func fetchGroups() async throws -> [FeemoGroup] {
        let response: GroupsResponse = try await client.get(path: "/groups")
        return response.groups.map { $0.toFeemoGroup() }
    }

    func fetchGroupFeed(groupId: String, cursor: String?) async throws -> [EmotionPost] {
        var path = "/groups/\(groupId)/feed"
        if let cursor { path += "?cursor=\(cursor.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cursor)" }
        let response: FeedResponse = try await client.get(path: path)
        return response.posts.map { $0.toEmotionPost() }
    }

    func createGroup(name: String) async throws -> FeemoGroup {
        struct Body: Encodable { let name: String }
        let dto: GroupDTO = try await client.post(path: "/groups", body: Body(name: name))
        return dto.toFeemoGroup()
    }
}
