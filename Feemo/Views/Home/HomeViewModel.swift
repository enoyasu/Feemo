import SwiftUI

@Observable
class HomeViewModel {
    var posts: [EmotionPost] = []
    var isLoading = false
    var errorMessage: String? = nil
    var selectedScope: FeedScope = .all

    enum FeedScope: String, CaseIterable {
        case all = "すべて"
        case closeFriends = "親しい友達"
    }

    private let postRepo: any PostRepositoryProtocol

    init(postRepo: any PostRepositoryProtocol) {
        self.postRepo = postRepo
    }

    func loadFeed() async {
        isLoading = true
        errorMessage = nil
        do {
            let scope = selectedScope == .closeFriends ? "close_friends" : "all"
            posts = try await postRepo.fetchFeed(scope: scope, groupId: nil, cursor: nil)
        } catch {
            errorMessage = "読み込みに失敗しました"
        }
        isLoading = false
    }

    func addReaction(to post: EmotionPost, reaction: ReactionType) async {
        do {
            let alreadyReacted = post.hasReacted(userId: "u1", reactionType: reaction)
            if alreadyReacted {
                try await postRepo.removeReaction(postId: post.id, reactionType: reaction)
            } else {
                try await postRepo.addReaction(postId: post.id, reactionType: reaction)
            }
            // Refresh the feed after reaction
            let scope = selectedScope == .closeFriends ? "close_friends" : "all"
            posts = try await postRepo.fetchFeed(scope: scope, groupId: nil, cursor: nil)
        } catch {
            errorMessage = "リアクションに失敗しました"
        }
    }

    func onPostCreated() async {
        await loadFeed()
    }
}
