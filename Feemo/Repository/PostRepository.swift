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
    private var myPosts: [EmotionPost] = MockPostRepository.makeMyPosts()

    private static func makeMyPosts() -> [EmotionPost] {
        let day: TimeInterval = 86400
        return [
            // 今日
            EmotionPost(
                id: "mine1", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.recovering.rawValue, emotionSecondary: nil,
                intensity: 3, shortNote: "すこしずつよくなってる",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-1800), expiresAt: nil,
                reactions: [
                    PostReaction(id: "mr1", postId: "mine1", reactorUserId: "u2", reactionType: .gyu, createdAt: Date()),
                    PostReaction(id: "mr2", postId: "mine1", reactorUserId: "u4", reactionType: .gyu, createdAt: Date()),
                    PostReaction(id: "mr3", postId: "mine1", reactorUserId: "u3", reactionType: .erai, createdAt: Date()),
                ],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            // 昨日
            EmotionPost(
                id: "mine2", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.overwhelmed.rawValue, emotionSecondary: nil,
                intensity: 4, shortNote: "もうだめかもしれない",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-day - 3600), expiresAt: nil,
                reactions: [
                    PostReaction(id: "mr4", postId: "mine2", reactorUserId: "u2", reactionType: .gyu, createdAt: Date()),
                    PostReaction(id: "mr5", postId: "mine2", reactorUserId: "u7", reactionType: .mimamoru, createdAt: Date()),
                    PostReaction(id: "mr6", postId: "mine2", reactorUserId: "u4", reactionType: .wakaru, createdAt: Date()),
                ],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            EmotionPost(
                id: "mine3", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.calm.rawValue, emotionSecondary: nil,
                intensity: 2, shortNote: nil,
                visibilityScope: .private,
                createdAt: Date().addingTimeInterval(-day - 18000), expiresAt: nil,
                reactions: [],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            // 2日前
            EmotionPost(
                id: "mine4", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.happy.rawValue, emotionSecondary: nil,
                intensity: 5, shortNote: "ライブ最高だった",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-day * 2 - 7200), expiresAt: nil,
                reactions: [
                    PostReaction(id: "mr7", postId: "mine4", reactorUserId: "u3", reactionType: .ureshii, createdAt: Date()),
                    PostReaction(id: "mr8", postId: "mine4", reactorUserId: "u5", reactionType: .ureshii, createdAt: Date()),
                    PostReaction(id: "mr9", postId: "mine4", reactorUserId: "u7", reactionType: .ureshii, createdAt: Date()),
                    PostReaction(id: "mr10", postId: "mine4", reactorUserId: "u9", reactionType: .erai, createdAt: Date()),
                ],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            EmotionPost(
                id: "mine5", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.anxious.rawValue, emotionSecondary: nil,
                intensity: 3, shortNote: "緊張してる",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-day * 2 - 21600), expiresAt: nil,
                reactions: [
                    PostReaction(id: "mr11", postId: "mine5", reactorUserId: "u2", reactionType: .wakaru, createdAt: Date()),
                ],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            // 3日前
            EmotionPost(
                id: "mine6", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.sleepy.rawValue, emotionSecondary: nil,
                intensity: 4, shortNote: "ねむすぎてむり",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-day * 3 - 5400), expiresAt: nil,
                reactions: [
                    PostReaction(id: "mr12", postId: "mine6", reactorUserId: "u4", reactionType: .wakaru, createdAt: Date()),
                    PostReaction(id: "mr13", postId: "mine6", reactorUserId: "u6", reactionType: .wakaru, createdAt: Date()),
                ],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            EmotionPost(
                id: "mine7", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.fulfilled.rawValue, emotionSecondary: nil,
                intensity: 4, shortNote: "夕焼けきれいだった",
                visibilityScope: .private,
                createdAt: Date().addingTimeInterval(-day * 3 - 32400), expiresAt: nil,
                reactions: [],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            // 4日前
            EmotionPost(
                id: "mine8", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.impatient.rawValue, emotionSecondary: nil,
                intensity: 3, shortNote: "締め切りこわい",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-day * 4 - 10800), expiresAt: nil,
                reactions: [
                    PostReaction(id: "mr14", postId: "mine8", reactorUserId: "u3", reactionType: .erai, createdAt: Date()),
                ],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            // 5日前
            EmotionPost(
                id: "mine9", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.calm.rawValue, emotionSecondary: nil,
                intensity: 3, shortNote: "コーヒーうまい",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-day * 5 - 9000), expiresAt: nil,
                reactions: [],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            EmotionPost(
                id: "mine10", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.void.rawValue, emotionSecondary: nil,
                intensity: 2, shortNote: nil,
                visibilityScope: .private,
                createdAt: Date().addingTimeInterval(-day * 5 - 54000), expiresAt: nil,
                reactions: [],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            // 6日前
            EmotionPost(
                id: "mine11", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.happy.rawValue, emotionSecondary: nil,
                intensity: 4, shortNote: "いい一日だった",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-day * 6 - 14400), expiresAt: nil,
                reactions: [
                    PostReaction(id: "mr15", postId: "mine11", reactorUserId: "u2", reactionType: .ureshii, createdAt: Date()),
                    PostReaction(id: "mr16", postId: "mine11", reactorUserId: "u5", reactionType: .ureshii, createdAt: Date()),
                ],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            EmotionPost(
                id: "mine12", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.recovering.rawValue, emotionSecondary: nil,
                intensity: 2, shortNote: "やっと立ち直れた",
                visibilityScope: .closeFriends,
                createdAt: Date().addingTimeInterval(-day * 6 - 36000), expiresAt: nil,
                reactions: [
                    PostReaction(id: "mr17", postId: "mine12", reactorUserId: "u3", reactionType: .gyu, createdAt: Date()),
                ],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
            // 7日前
            EmotionPost(
                id: "mine13", userId: "u1", groupId: nil,
                emotionPrimary: EmotionType.sleepy.rawValue, emotionSecondary: nil,
                intensity: 5, shortNote: "眠れてない",
                visibilityScope: .private,
                createdAt: Date().addingTimeInterval(-day * 7 - 7200), expiresAt: nil,
                reactions: [],
                authorNickname: "ゆうな", authorIconColor: "A8D8C0"
            ),
        ]
    }

    // Expose for MockProfileRepository preview use
    var myPostsForPreview: [EmotionPost] { myPosts }

    func fetchFeed(scope: String, groupId: String?, cursor: String?) async throws -> [EmotionPost] {
        try await Task.sleep(nanoseconds: 400_000_000)
        // 「自分だけ」スコープの投稿はフィードに出さない（マイページ専用）
        return posts.filter { $0.visibilityScope != .private }
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
