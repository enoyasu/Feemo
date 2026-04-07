import SwiftUI

struct NotificationListView: View {
    @State private var viewModel: NotificationListViewModel

    init(notificationRepo: any NotificationRepositoryProtocol) {
        _viewModel = State(initialValue: NotificationListViewModel(notificationRepo: notificationRepo))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.Colors.background
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("通知")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.unreadCount > 0 {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("すべて既読") {
                            Task { await viewModel.markAllAsRead() }
                        }
                        .font(DesignTokens.Typography.callout)
                        .foregroundStyle(DesignTokens.Colors.accent)
                    }
                }
            }
        }
        .task {
            await viewModel.loadNotifications()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.notifications.isEmpty {
            ProgressView()
                .tint(DesignTokens.Colors.accent)
        } else if viewModel.notifications.isEmpty {
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text("通知はありません")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.secondaryText)
            }
        } else {
            ScrollView {
                LazyVStack(spacing: 1) {
                    ForEach(viewModel.notifications) { notification in
                        NotificationRowView(notification: notification)
                            .onTapGesture {
                                Task { await viewModel.markAsRead(id: notification.id) }
                            }
                    }
                }
                .background(DesignTokens.Colors.surface)
                .cornerRadius(DesignTokens.Radius.large)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.top, DesignTokens.Spacing.sm)
            }
            .refreshable {
                await viewModel.loadNotifications()
            }
        }
    }
}

struct NotificationRowView: View {
    let notification: AppNotification

    private var iconName: String {
        switch notification.type {
        case .reaction: return "heart.fill"
        case .groupInvite: return "person.badge.plus.fill"
        case .syncTime: return "bell.fill"
        }
    }

    private var iconColor: Color {
        switch notification.type {
        case .reaction: return DesignTokens.Colors.accent
        case .groupInvite: return Color.fromHex("9BC89B")
        case .syncTime: return Color.fromHex("F9C784")
        }
    }

    private var timeAgo: String {
        let interval = Date().timeIntervalSince(notification.createdAt)
        if interval < 60 { return "たった今" }
        if interval < 3600 { return "\(Int(interval / 60))分前" }
        if interval < 86400 { return "\(Int(interval / 3600))時間前" }
        return "\(Int(interval / 86400))日前"
    }

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(notification.title)
                    .font(DesignTokens.Typography.callout)
                    .fontWeight(notification.isRead ? .regular : .semibold)
                    .foregroundStyle(DesignTokens.Colors.primaryText)

                Text(notification.body)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Colors.secondaryText)

                Text(timeAgo)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Colors.tertiaryText)
            }

            Spacer()

            if !notification.isRead {
                Circle()
                    .fill(DesignTokens.Colors.accent)
                    .frame(width: 8, height: 8)
                    .padding(.top, 4)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            notification.isRead
                ? DesignTokens.Colors.surface
                : DesignTokens.Colors.accentSoft.opacity(0.4)
        )
    }
}

#Preview {
    NotificationListView(notificationRepo: MockNotificationRepository())
}
