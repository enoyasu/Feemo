import SwiftUI

struct GroupDetailView: View {
    let group: FeemoGroup
    let postRepo: any PostRepositoryProtocol
    @Environment(AppState.self) private var appState
    @State private var posts: [EmotionPost] = []
    @State private var isLoading = false
    @State private var showPostComposer = false

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            content
        }
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showPostComposer = true
                } label: {
                    ZStack {
                        Circle()
                            .fill(DesignTokens.Colors.accent)
                            .frame(width: 32, height: 32)
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showPostComposer) {
            PostComposerSheet(postRepo: postRepo)
        }
        .task {
            await loadFeed()
        }
    }

    private func loadFeed() async {
        isLoading = true
        do {
            posts = try await postRepo.fetchFeed(scope: "group", groupId: group.id, cursor: nil)
        } catch {
            // silent fail
        }
        isLoading = false
    }

    @ViewBuilder
    private var content: some View {
        if isLoading && posts.isEmpty {
            ProgressView()
                .tint(DesignTokens.Colors.accent)
        } else if posts.isEmpty {
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("まだ感情が置かれていません")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.secondaryText)
                Button("最初のひと粒を置く") {
                    showPostComposer = true
                }
                .font(DesignTokens.Typography.callout)
                .foregroundStyle(DesignTokens.Colors.accent)
            }
        } else {
            ScrollView {
                LazyVStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(posts) { post in
                        EmotionCardView(
                            post: post,
                            currentUserId: appState.currentUser?.id ?? ""
                        )
                        .padding(.horizontal, DesignTokens.Spacing.md)
                    }
                    Spacer(minLength: DesignTokens.Spacing.xxl)
                }
                .padding(.top, DesignTokens.Spacing.sm)
            }
            .refreshable {
                await loadFeed()
            }
        }
    }
}

#Preview {
    NavigationStack {
        GroupDetailView(
            group: FeemoGroup.mockGroups[0],
            postRepo: MockPostRepository()
        )
        .environment(AppState())
    }
}
