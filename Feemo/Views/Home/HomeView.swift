import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: HomeViewModel
    @Binding var showPostComposer: Bool

    init(
        postRepo: any PostRepositoryProtocol,
        groupRepo: any GroupRepositoryProtocol,
        showPostComposer: Binding<Bool>
    ) {
        _viewModel = State(initialValue: HomeViewModel(postRepo: postRepo))
        _showPostComposer = showPostComposer
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.Colors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Scope Selector
                    scopeSelector

                    // Feed
                    feedContent
                }
            }
            .navigationTitle("Feemo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showPostComposer = true
                    } label: {
                        ZStack {
                            Circle()
                                .fill(DesignTokens.Colors.accent)
                                .frame(width: 36, height: 36)
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadFeed()
        }
        .onChange(of: viewModel.selectedScope) {
            Task { await viewModel.loadFeed() }
        }
    }

    private var scopeSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(HomeViewModel.FeedScope.allCases, id: \.self) { scope in
                    Button {
                        viewModel.selectedScope = scope
                    } label: {
                        Text(scope.rawValue)
                            .font(DesignTokens.Typography.callout)
                            .foregroundStyle(
                                viewModel.selectedScope == scope
                                    ? DesignTokens.Colors.accent
                                    : DesignTokens.Colors.secondaryText
                            )
                            .padding(.horizontal, DesignTokens.Spacing.md)
                            .padding(.vertical, DesignTokens.Spacing.sm)
                            .background(
                                viewModel.selectedScope == scope
                                    ? DesignTokens.Colors.accentSoft
                                    : Color.clear
                            )
                            .cornerRadius(DesignTokens.Radius.extraLarge)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
        }
        .background(DesignTokens.Colors.surface)
    }

    @ViewBuilder
    private var feedContent: some View {
        if viewModel.isLoading && viewModel.posts.isEmpty {
            Spacer()
            ProgressView()
                .tint(DesignTokens.Colors.accent)
            Spacer()
        } else if let error = viewModel.errorMessage {
            Spacer()
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text(error)
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.secondaryText)
                Button("もう一度試す") {
                    Task { await viewModel.loadFeed() }
                }
                .tint(DesignTokens.Colors.accent)
            }
            Spacer()
        } else if viewModel.posts.isEmpty {
            Spacer()
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("まだ誰も気持ちを置いていません")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.secondaryText)
                Button("最初のひと粒を置いてみよう") {
                    showPostComposer = true
                }
                .font(DesignTokens.Typography.callout)
                .foregroundStyle(DesignTokens.Colors.accent)
            }
            Spacer()
        } else {
            ScrollView {
                LazyVStack(spacing: DesignTokens.Spacing.sm) {
                    // Post composer prompt
                    postPromptCard

                    ForEach(viewModel.posts) { post in
                        EmotionCardView(
                            post: post,
                            currentUserId: appState.currentUser?.id ?? ""
                        ) { reaction in
                            Task { await viewModel.addReaction(to: post, reaction: reaction) }
                        }
                        .padding(.horizontal, DesignTokens.Spacing.md)
                    }

                    Spacer(minLength: DesignTokens.Spacing.xxl)
                }
                .padding(.top, DesignTokens.Spacing.sm)
            }
            .refreshable {
                await viewModel.loadFeed()
            }
        }
    }

    private var postPromptCard: some View {
        Button {
            showPostComposer = true
        } label: {
            HStack {
                UserIconView(
                    nickname: appState.currentUser?.nickname ?? "あなた",
                    colorHex: appState.currentUser?.iconColor ?? "A8D8C0",
                    size: 36
                )
                Text("いまの気分を置く...")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.tertiaryText)
                Spacer()
            }
            .padding(DesignTokens.Spacing.md)
            .cardStyle()
        }
        .buttonStyle(.plain)
        .padding(.horizontal, DesignTokens.Spacing.md)
    }
}

#Preview {
    @Previewable @State var showPost = false
    HomeView(
        postRepo: MockPostRepository(),
        groupRepo: MockGroupRepository(),
        showPostComposer: $showPost
    )
    .environment(AppState())
}
