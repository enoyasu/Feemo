import SwiftUI

@Observable
class GroupListViewModel {
    var groups: [FeemoGroup] = []
    var isLoading = false
    var errorMessage: String? = nil

    private let groupRepo: any GroupRepositoryProtocol

    init(groupRepo: any GroupRepositoryProtocol) {
        self.groupRepo = groupRepo
    }

    func loadGroups() async {
        isLoading = true
        errorMessage = nil
        do {
            groups = try await groupRepo.fetchGroups()
        } catch {
            errorMessage = "読み込みに失敗しました"
        }
        isLoading = false
    }

    func createGroup(name: String) async -> FeemoGroup? {
        do {
            let group = try await groupRepo.createGroup(name: name)
            groups.append(group)
            return group
        } catch {
            errorMessage = "グループの作成に失敗しました"
            return nil
        }
    }
}
