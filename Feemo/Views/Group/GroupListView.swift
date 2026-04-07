import SwiftUI

struct GroupListView: View {
    @State private var viewModel: GroupListViewModel
    @State private var showCreateGroup = false
    let postRepo: any PostRepositoryProtocol

    init(groupRepo: any GroupRepositoryProtocol, postRepo: any PostRepositoryProtocol) {
        _viewModel = State(initialValue: GroupListViewModel(groupRepo: groupRepo))
        self.postRepo = postRepo
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.Colors.background
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("グループ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showCreateGroup = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(DesignTokens.Colors.accent)
                    }
                }
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView { name in
                    Task {
                        _ = await viewModel.createGroup(name: name)
                    }
                }
            }
        }
        .task {
            await viewModel.loadGroups()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.groups.isEmpty {
            ProgressView()
                .tint(DesignTokens.Colors.accent)
        } else if viewModel.groups.isEmpty {
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("グループがありません")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.secondaryText)
                Button("グループを作る") {
                    showCreateGroup = true
                }
                .font(DesignTokens.Typography.callout)
                .foregroundStyle(DesignTokens.Colors.accent)
            }
        } else {
            ScrollView {
                LazyVStack(spacing: DesignTokens.Spacing.sm) {
                    ForEach(viewModel.groups) { group in
                        NavigationLink {
                            GroupDetailView(group: group, postRepo: postRepo)
                        } label: {
                            GroupRowView(group: group)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                    }
                }
                .padding(.vertical, DesignTokens.Spacing.sm)
            }
            .refreshable {
                await viewModel.loadGroups()
            }
        }
    }
}

struct GroupRowView: View {
    let group: FeemoGroup

    private var latestEmotion: EmotionType? {
        group.latestEmotion.flatMap { EmotionType(rawValue: $0) }
    }

    private var timeAgo: String? {
        guard let date = group.latestPostAt else { return nil }
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "たった今" }
        if interval < 3600 { return "\(Int(interval / 60))分前" }
        if interval < 86400 { return "\(Int(interval / 3600))時間前" }
        return "\(Int(interval / 86400))日前"
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            // Group Icon
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                    .fill(latestEmotion?.lightColor ?? DesignTokens.Colors.surfaceSecondary)
                    .frame(width: 48, height: 48)
                Text(String(group.name.prefix(1)))
                    .font(DesignTokens.Typography.title)
                    .foregroundStyle(latestEmotion?.color ?? DesignTokens.Colors.secondaryText)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(group.name)
                    .font(DesignTokens.Typography.headline)
                    .foregroundStyle(DesignTokens.Colors.primaryText)

                HStack(spacing: DesignTokens.Spacing.xs) {
                    Text("\(group.memberCount)人")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.secondaryText)

                    if let timeAgo {
                        Text("・")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.tertiaryText)
                        Text(timeAgo)
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.tertiaryText)
                    }
                }
            }

            Spacer()

            if let emotion = latestEmotion {
                Text(emotion.rawValue)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(emotion.color)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(emotion.lightColor)
                    .cornerRadius(DesignTokens.Radius.small)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(DesignTokens.Colors.tertiaryText)
        }
        .padding(DesignTokens.Spacing.md)
        .cardStyle()
    }
}

#Preview {
    GroupListView(groupRepo: MockGroupRepository(), postRepo: MockPostRepository())
        .environment(AppState())
}
