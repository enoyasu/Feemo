import SwiftUI

@Observable
class PostComposerViewModel {
    var selectedEmotion: EmotionType? = nil
    var intensity: Double = 3
    var shortNote: String = ""
    var selectedScope: VisibilityScope = .closeFriends
    var selectedGroupId: String? = nil
    var isSubmitting = false
    var errorMessage: String? = nil
    var didSucceed = false

    private let postRepo: any PostRepositoryProtocol

    init(postRepo: any PostRepositoryProtocol) {
        self.postRepo = postRepo
    }

    var canSubmit: Bool {
        selectedEmotion != nil && !isSubmitting
    }

    func submit() async {
        guard let emotion = selectedEmotion else { return }
        isSubmitting = true
        errorMessage = nil

        let request = CreatePostRequest(
            emotionPrimary: emotion.rawValue,
            emotionSecondary: nil,
            intensity: Int(intensity),
            shortNote: shortNote.isEmpty ? nil : shortNote,
            visibilityScope: selectedScope.rawValue,
            groupId: selectedGroupId
        )

        do {
            _ = try await postRepo.createPost(request)
            didSucceed = true
        } catch {
            errorMessage = "投稿できませんでした。もう一度お試しください。"
        }
        isSubmitting = false
    }
}
