import SwiftUI

struct MyPageView: View {
    @Environment(AppState.self) private var appState
    @State private var weeklySummary: WeeklySummary? = nil
    @State private var recentPosts: [EmotionPost] = []
    @State private var isLoading = false
    @State private var showSettings = false
    @State private var showMoodLog = false

    let profileRepo: any ProfileRepositoryProtocol
    let postRepo: any PostRepositoryProtocol

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignTokens.Spacing.lg) {
                        profileSection
                        if let summary = weeklySummary {
                            weeklySummarySection(summary)
                        }
                        recentEmotionsSection
                        Spacer(minLength: DesignTokens.Spacing.xxl)
                    }
                    .padding(.top, DesignTokens.Spacing.md)
                }
            }
            .navigationTitle("マイページ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                            .foregroundStyle(DesignTokens.Colors.secondaryText)
                    }
                }
            }
            .navigationDestination(isPresented: $showSettings) {
                SettingsView()
            }
            .navigationDestination(isPresented: $showMoodLog) {
                MoodLogView(profileRepo: profileRepo)
            }
        }
        .task {
            await loadData()
        }
    }

    private func loadData() async {
        isLoading = true
        async let summaryTask = try? profileRepo.fetchWeeklySummary()
        async let postsTask = try? profileRepo.fetchMoodLog(cursor: nil)
        let (summary, posts) = await (summaryTask, postsTask)
        weeklySummary = summary
        recentPosts = Array((posts ?? []).prefix(3))
        isLoading = false
    }

    private var profileSection: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            UserIconView(
                nickname: appState.currentUser?.nickname ?? "あなた",
                colorHex: appState.currentUser?.iconColor ?? "A8D8C0",
                size: 64
            )

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(appState.currentUser?.nickname ?? "あなた")
                    .font(DesignTokens.Typography.title)
                    .foregroundStyle(DesignTokens.Colors.primaryText)

                Text("感情を置きはじめて\(daysSinceJoined)日")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Colors.secondaryText)
            }

            Spacer()
        }
        .padding(DesignTokens.Spacing.md)
        .cardStyle()
        .padding(.horizontal, DesignTokens.Spacing.md)
    }

    private var daysSinceJoined: Int {
        guard let user = appState.currentUser else { return 0 }
        return max(0, Int(Date().timeIntervalSince(user.createdAt) / 86400))
    }

    private func weeklySummarySection(_ summary: WeeklySummary) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text("今週のまとめ")
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(DesignTokens.Colors.primaryText)
                .padding(.horizontal, DesignTokens.Spacing.md)

            VStack(spacing: DesignTokens.Spacing.sm) {
                HStack(spacing: DesignTokens.Spacing.md) {
                    SummaryStatView(
                        value: "\(summary.postCount)",
                        label: "投稿した感情"
                    )

                    Divider()

                    SummaryStatView(
                        value: "\(summary.topEmotions.count)",
                        label: "使った感情の種類"
                    )
                }
                .padding(DesignTokens.Spacing.md)
                .cardStyle()

                if !summary.topEmotions.isEmpty {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("よく置いた気分")
                            .font(DesignTokens.Typography.callout)
                            .foregroundStyle(DesignTokens.Colors.secondaryText)

                        HStack(spacing: DesignTokens.Spacing.sm) {
                            ForEach(summary.topEmotions, id: \.self) { emotionRaw in
                                if let emotion = EmotionType(rawValue: emotionRaw) {
                                    Text(emotion.rawValue)
                                        .font(DesignTokens.Typography.caption)
                                        .foregroundStyle(emotion.color)
                                        .padding(.horizontal, DesignTokens.Spacing.sm)
                                        .padding(.vertical, 4)
                                        .background(emotion.lightColor)
                                        .cornerRadius(DesignTokens.Radius.small)
                                }
                            }
                        }
                    }
                    .padding(DesignTokens.Spacing.md)
                    .cardStyle()
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
    }

    private var recentEmotionsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("最近の気分")
                    .font(DesignTokens.Typography.headline)
                    .foregroundStyle(DesignTokens.Colors.primaryText)
                Spacer()
                Button("すべて見る") {
                    showMoodLog = true
                }
                .font(DesignTokens.Typography.callout)
                .foregroundStyle(DesignTokens.Colors.accent)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)

            if recentPosts.isEmpty && !isLoading {
                Text("まだ感情を置いていません")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.secondaryText)
                    .padding(.horizontal, DesignTokens.Spacing.md)
            } else {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(recentPosts) { post in
                        MiniPostRowView(post: post)
                            .padding(.horizontal, DesignTokens.Spacing.md)
                    }
                }
            }
        }
    }
}

struct SummaryStatView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(DesignTokens.Typography.largeTitle)
                .foregroundStyle(DesignTokens.Colors.primaryText)
            Text(label)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Colors.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }
}

struct MiniPostRowView: View {
    let post: EmotionPost

    private var emotion: EmotionType? {
        EmotionType(rawValue: post.emotionPrimary)
    }

    private var dateLabel: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: post.createdAt)
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Circle()
                .fill(emotion?.color ?? DesignTokens.Colors.border)
                .frame(width: 10, height: 10)

            Text(post.emotionPrimary)
                .font(DesignTokens.Typography.callout)
                .foregroundStyle(emotion?.color ?? DesignTokens.Colors.secondaryText)

            IntensityDotsView(
                intensity: post.intensity,
                color: emotion?.color ?? DesignTokens.Colors.border,
                size: 6
            )

            if let note = post.shortNote {
                Text(note)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Colors.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            Text(dateLabel)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Colors.tertiaryText)
        }
        .padding(DesignTokens.Spacing.md)
        .cardStyle()
    }
}

#Preview {
    MyPageView(
        profileRepo: MockProfileRepository(),
        postRepo: MockPostRepository()
    )
    .environment(AppState())
}
