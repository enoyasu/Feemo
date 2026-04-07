import SwiftUI

struct ReactionBarView: View {
    let post: EmotionPost
    let currentUserId: String
    var onReaction: ((ReactionType) -> Void)? = nil

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(ReactionType.allCases) { reaction in
                    let count = post.reactionCount(for: reaction)
                    let hasReacted = post.hasReacted(userId: currentUserId, reactionType: reaction)
                    let emotion = EmotionType(rawValue: post.emotionPrimary)

                    if count > 0 || true { // Show all reactions
                        ReactionChipView(
                            label: reaction.label,
                            count: count,
                            isActive: hasReacted,
                            activeColor: emotion?.color ?? DesignTokens.Colors.accent
                        ) {
                            onReaction?(reaction)
                        }
                    }
                }
            }
        }
    }
}

struct ReactionChipView: View {
    let label: String
    let count: Int
    let isActive: Bool
    let activeColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text(label)
                    .font(DesignTokens.Typography.small)
                if count > 0 {
                    Text("\(count)")
                        .font(DesignTokens.Typography.small)
                }
            }
            .foregroundStyle(isActive ? activeColor : DesignTokens.Colors.secondaryText)
            .padding(.horizontal, 8)
            .padding(.vertical, 5)
            .background(
                isActive
                    ? activeColor.opacity(0.12)
                    : DesignTokens.Colors.surfaceSecondary
            )
            .cornerRadius(DesignTokens.Radius.small)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ReactionBarView(post: EmotionPost.mockPosts[1], currentUserId: "u1")
        .padding()
}
