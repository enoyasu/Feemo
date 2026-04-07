import Foundation

// MARK: - API Response Types
struct FeedResponse: Decodable {
    let posts: [PostDTO]
    let nextCursor: String?
}

struct PostDTO: Decodable {
    let id: String
    let userId: String
    let groupId: String?
    let emotionPrimary: String
    let emotionSecondary: String?
    let intensity: Int
    let shortNote: String?
    let visibilityScope: String
    let createdAt: String
    let expiresAt: String?
    let reactions: [ReactionDTO]
    let authorNickname: String
    let authorIconColor: String

    func toEmotionPost() -> EmotionPost {
        EmotionPost(
            id: id,
            userId: userId,
            groupId: groupId,
            emotionPrimary: emotionPrimary,
            emotionSecondary: emotionSecondary,
            intensity: intensity,
            shortNote: shortNote,
            visibilityScope: VisibilityScope(rawValue: visibilityScope) ?? .closeFriends,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date(),
            expiresAt: expiresAt.flatMap { ISO8601DateFormatter().date(from: $0) },
            reactions: reactions.map { $0.toPostReaction() },
            authorNickname: authorNickname,
            authorIconColor: authorIconColor
        )
    }
}

struct ReactionDTO: Decodable {
    let id: String
    let postId: String
    let reactorUserId: String
    let reactionType: String
    let createdAt: String

    func toPostReaction() -> PostReaction {
        PostReaction(
            id: id,
            postId: postId,
            reactorUserId: reactorUserId,
            reactionType: ReactionType(rawValue: reactionType) ?? .wakaru,
            createdAt: ISO8601DateFormatter().date(from: createdAt) ?? Date()
        )
    }
}

// MARK: - Live Post Repository
class LivePostRepository: PostRepositoryProtocol {
    private let client = APIClient.shared

    func fetchFeed(scope: String, groupId: String?, cursor: String?) async throws -> [EmotionPost] {
        var path = "/posts/feed?scope=\(scope)"
        if let groupId { path += "&group_id=\(groupId)" }
        if let cursor { path += "&cursor=\(cursor.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cursor)" }

        let response: FeedResponse = try await client.get(path: path)
        return response.posts.map { $0.toEmotionPost() }
    }

    func fetchMyPosts(cursor: String?) async throws -> [EmotionPost] {
        var path = "/posts/mine"
        if let cursor { path += "?cursor=\(cursor.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cursor)" }

        let response: FeedResponse = try await client.get(path: path)
        return response.posts.map { $0.toEmotionPost() }
    }

    func createPost(_ request: CreatePostRequest) async throws -> EmotionPost {
        let dto: PostDTO = try await client.post(path: "/posts", body: request)
        return dto.toEmotionPost()
    }

    func deletePost(id: String) async throws {
        try await client.delete(path: "/posts/\(id)")
    }

    func addReaction(postId: String, reactionType: ReactionType) async throws {
        struct Body: Encodable { let reactionType: String }
        let _: EmptyResponse = try await client.post(
            path: "/posts/\(postId)/reactions",
            body: Body(reactionType: reactionType.rawValue)
        )
    }

    func removeReaction(postId: String, reactionType: ReactionType) async throws {
        try await client.delete(path: "/posts/\(postId)/reactions/\(reactionType.rawValue)")
    }
}

struct EmptyResponse: Decodable {}
