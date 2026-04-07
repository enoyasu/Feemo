import Foundation

// MARK: - Group Repository Protocol
protocol GroupRepositoryProtocol {
    func fetchGroups() async throws -> [FeemoGroup]
    func fetchGroupFeed(groupId: String, cursor: String?) async throws -> [EmotionPost]
    func createGroup(name: String) async throws -> FeemoGroup
}

// MARK: - Mock Group Repository
class MockGroupRepository: GroupRepositoryProtocol {
    private var groups: [FeemoGroup] = FeemoGroup.mockGroups

    func fetchGroups() async throws -> [FeemoGroup] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return groups
    }

    func fetchGroupFeed(groupId: String, cursor: String?) async throws -> [EmotionPost] {
        try await Task.sleep(nanoseconds: 400_000_000)
        return EmotionPost.mockPosts.filter { $0.groupId == groupId }
    }

    func createGroup(name: String) async throws -> FeemoGroup {
        try await Task.sleep(nanoseconds: 500_000_000)
        let newGroup = FeemoGroup(
            id: UUID().uuidString,
            name: name,
            ownerUserId: "u1",
            memberCount: 1,
            latestPostAt: nil,
            latestEmotion: nil,
            createdAt: Date()
        )
        groups.append(newGroup)
        return newGroup
    }
}
