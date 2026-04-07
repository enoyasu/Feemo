import SwiftUI

struct MainTabView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedTab = 0
    @State private var showPostComposer = false

    // Repositories — live when API is configured, mock otherwise
    private let postRepo: any PostRepositoryProtocol
    private let groupRepo: any GroupRepositoryProtocol
    private let notificationRepo: any NotificationRepositoryProtocol
    private let profileRepo: any ProfileRepositoryProtocol

    init() {
        if APIConfig.resolveIsConfigured() {
            postRepo = LivePostRepository()
            groupRepo = LiveGroupRepository()
            notificationRepo = LiveNotificationRepository()
            profileRepo = LiveProfileRepository()
        } else {
            postRepo = MockPostRepository()
            groupRepo = MockGroupRepository()
            notificationRepo = MockNotificationRepository()
            profileRepo = MockProfileRepository()
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(postRepo: postRepo, groupRepo: groupRepo, showPostComposer: $showPostComposer)
                .tabItem {
                    Label("ホーム", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            GroupListView(groupRepo: groupRepo, postRepo: postRepo)
                .tabItem {
                    Label("グループ", systemImage: selectedTab == 1 ? "person.2.fill" : "person.2")
                }
                .tag(1)

            NotificationListView(notificationRepo: notificationRepo)
                .tabItem {
                    Label("通知", systemImage: selectedTab == 2 ? "bell.fill" : "bell")
                }
                .tag(2)

            MyPageView(profileRepo: profileRepo, postRepo: postRepo)
                .tabItem {
                    Label("マイページ", systemImage: selectedTab == 3 ? "person.fill" : "person")
                }
                .tag(3)
        }
        .tint(DesignTokens.Colors.accent)
        .sheet(isPresented: $showPostComposer) {
            PostComposerSheet(postRepo: postRepo)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppState())
}
