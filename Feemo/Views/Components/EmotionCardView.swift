import SwiftUI

struct EmotionCardView: View {
    let post: EmotionPost
    let currentUserId: String
    var onReaction: ((ReactionType) -> Void)? = nil

    private var emotion: EmotionType? {
        EmotionType(rawValue: post.emotionPrimary)
    }

    private var emotionColor: Color {
        emotion?.color ?? DesignTokens.Colors.border
    }

    private var timeAgo: String {
        let interval = Date().timeIntervalSince(post.createdAt)
        if interval < 60 { return "たった今" }
        if interval < 3600 { return "\(Int(interval / 60))分前" }
        if interval < 86400 { return "\(Int(interval / 3600))時間前" }
        return "\(Int(interval / 86400))日前"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Color accent bar
            Rectangle()
                .fill(emotionColor)
                .frame(height: 4)
                .cornerRadius(2)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                // Header
                HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                    UserIconView(
                        nickname: post.authorNickname,
                        colorHex: post.authorIconColor,
                        size: 34
                    )

                    VStack(alignment: .leading, spacing: 2) {
                        Text(post.authorNickname)
                            .font(DesignTokens.Typography.callout)
                            .fontWeight(.medium)
                            .foregroundStyle(DesignTokens.Colors.primaryText)

                        Text(timeAgo)
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.tertiaryText)
                    }

                    Spacer()

                    // Visibility badge
                    if post.visibilityScope == .private {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(DesignTokens.Colors.tertiaryText)
                    }
                }

                // Emotion + Intensity
                HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                    Text(post.emotionPrimary)
                        .font(DesignTokens.Typography.headline)
                        .foregroundStyle(emotionColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(emotionColor.opacity(0.15))
                        .cornerRadius(DesignTokens.Radius.small)

                    IntensityDotsView(intensity: post.intensity, color: emotionColor)
                }

                // Note
                if let note = post.shortNote, !note.isEmpty {
                    Text(note)
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(DesignTokens.Colors.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Reactions
                ReactionBarView(
                    post: post,
                    currentUserId: currentUserId,
                    onReaction: onReaction
                )
            }
            .padding(DesignTokens.Spacing.md)
        }
        .cardStyle()
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 12) {
            ForEach(EmotionPost.mockPosts) { post in
                EmotionCardView(post: post, currentUserId: "u1")
                    .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    .background(DesignTokens.Colors.background)
}
