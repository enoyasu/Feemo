import SwiftUI

struct MoodLogView: View {
    let profileRepo: any ProfileRepositoryProtocol
    @State private var posts: [EmotionPost] = []
    @State private var isLoading = false

    private var groupedByDate: [(String, [EmotionPost])] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月d日"

        var groups: [(String, [EmotionPost])] = []
        var currentKey = ""
        var currentGroup: [EmotionPost] = []

        for post in posts {
            let key = formatter.string(from: post.createdAt)
            if key != currentKey {
                if !currentGroup.isEmpty {
                    groups.append((currentKey, currentGroup))
                }
                currentKey = key
                currentGroup = [post]
            } else {
                currentGroup.append(post)
            }
        }
        if !currentGroup.isEmpty {
            groups.append((currentKey, currentGroup))
        }
        return groups
    }

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            if isLoading && posts.isEmpty {
                ProgressView()
                    .tint(DesignTokens.Colors.accent)
            } else if posts.isEmpty {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Text("感情ログはまだありません")
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(DesignTokens.Colors.secondaryText)
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                        ForEach(groupedByDate, id: \.0) { (dateLabel, dayPosts) in
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                                Text(dateLabel)
                                    .font(DesignTokens.Typography.callout)
                                    .foregroundStyle(DesignTokens.Colors.secondaryText)
                                    .padding(.horizontal, DesignTokens.Spacing.md)

                                VStack(spacing: DesignTokens.Spacing.sm) {
                                    ForEach(dayPosts) { post in
                                        MoodLogRowView(post: post)
                                            .padding(.horizontal, DesignTokens.Spacing.md)
                                    }
                                }
                            }
                        }
                        Spacer(minLength: DesignTokens.Spacing.xxl)
                    }
                    .padding(.top, DesignTokens.Spacing.sm)
                }
                .refreshable {
                    await loadPosts()
                }
            }
        }
        .navigationTitle("感情ログ")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadPosts()
        }
    }

    private func loadPosts() async {
        isLoading = true
        posts = (try? await profileRepo.fetchMoodLog(cursor: nil)) ?? []
        isLoading = false
    }
}

struct MoodLogRowView: View {
    let post: EmotionPost

    private var emotion: EmotionType? {
        EmotionType(rawValue: post.emotionPrimary)
    }

    private var timeLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: post.createdAt)
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Emotion indicator
            VStack(spacing: 2) {
                Circle()
                    .fill(emotion?.color ?? DesignTokens.Colors.border)
                    .frame(width: 10, height: 10)
            }
            .frame(width: 10)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text(post.emotionPrimary)
                        .font(DesignTokens.Typography.callout)
                        .foregroundStyle(emotion?.color ?? DesignTokens.Colors.secondaryText)

                    IntensityDotsView(
                        intensity: post.intensity,
                        color: emotion?.color ?? DesignTokens.Colors.border,
                        size: 6
                    )

                    Spacer()

                    Text(timeLabel)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.tertiaryText)
                }

                if let note = post.shortNote, !note.isEmpty {
                    Text(note)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.secondaryText)
                }

                HStack(spacing: DesignTokens.Spacing.xs) {
                    Image(systemName: post.visibilityScope == .private ? "lock.fill" : "person.2.fill")
                        .font(.system(size: 10))
                    Text(post.visibilityScope.label)
                        .font(DesignTokens.Typography.caption)
                }
                .foregroundStyle(DesignTokens.Colors.tertiaryText)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .cardStyle()
    }
}

#Preview {
    NavigationStack {
        MoodLogView(profileRepo: MockProfileRepository())
    }
}
