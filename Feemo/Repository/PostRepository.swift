import Foundation

// MARK: - Post Repository Protocol
protocol PostRepositoryProtocol {
    func fetchFeed(scope: String, groupId: String?, cursor: String?) async throws -> [EmotionPost]
    func fetchMyPosts(cursor: String?) async throws -> [EmotionPost]
    func createPost(_ request: CreatePostRequest) async throws -> EmotionPost
    func deletePost(id: String) async throws
    func addReaction(postId: String, reactionType: ReactionType) async throws
    func removeReaction(postId: String, reactionType: ReactionType) async throws
}

// MARK: - Request Models
struct CreatePostRequest: Encodable {
    let emotionPrimary: String
    let emotionSecondary: String?
    let intensity: Int
    let shortNote: String?
    let visibilityScope: String
    let groupId: String?
}

struct ReactionRequest: Encodable {
    let reactionType: String
}

// MARK: - Mock Post Repository
class MockPostRepository: PostRepositoryProtocol {
    private var posts: [EmotionPost] = EmotionPost.mockPosts
    private var myPosts: [EmotionPost] = [
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
        )
    ]

    func fetchFeed(scope: String, groupId: String?, cursor: String?) async throws -> [EmotionPost] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return posts
    }

    func fetchMyPosts(cursor: String?) async throws -> [EmotionPost] {
        try await Task.sleep(nanoseconds: 300_000_000)
        return myPosts
    }

    func createPost(_ request: CreatePostRequest) async throws -> EmotionPost {
        try await Task.sleep(nanoseconds: 500_000_000)
        let newPost = EmotionPost(
            id: UUID().uuidString,
            userId: "u1",
            groupId: request.groupId,
            emotionPrimary: request.emotionPrimary,
            emotionSecondary: request.emotionSecondary,
            intensity: request.intensity,
            shortNote: request.shortNote,
            visibilityScope: VisibilityScope(rawValue: request.visibilityScope) ?? .closeFriends,
            createdAt: Date(),
            expiresAt: nil,
            reactions: [],
            authorNickname: "あなた",
            authorIconColor: "A8D8C0"
        )
        posts.insert(newPost, at: 0)
        myPosts.insert(newPost, at: 0)
        return newPost
    }

    func deletePost(id: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        posts.removeAll { $0.id == id }
        myPosts.removeAll { $0.id == id }
    }

    func addReaction(postId: String, reactionType: ReactionType) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        let reaction = PostReaction(
            id: UUID().uuidString,
            postId: postId,
            reactorUserId: "u1",
            reactionType: reactionType,
            createdAt: Date()
        )
        posts[index].reactions.append(reaction)
    }

    func removeReaction(postId: String, reactionType: ReactionType) async throws {
        try await Task.sleep(nanoseconds: 200_000_000)
        guard let index = posts.firstIndex(where: { $0.id == postId }) else { return }
        posts[index].reactions.removeAll { $0.reactorUserId == "u1" && $0.reactionType == reactionType }
    }
}
