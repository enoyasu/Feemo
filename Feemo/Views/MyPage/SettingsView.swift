import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthManager.self) private var authManager
    @State private var nickname = ""
    @State private var notificationsEnabled = true
    @State private var syncTimeNotification = true
    @State private var showSignOutConfirm = false
    @State private var isEditingNickname = false

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            List {
                // Profile Section
                Section("プロフィール") {
                    HStack {
                        Text("ニックネーム")
                            .font(DesignTokens.Typography.body)
                        Spacer()
                        if isEditingNickname {
                            TextField("ニックネーム", text: $nickname)
                                .font(DesignTokens.Typography.body)
                                .multilineTextAlignment(.trailing)
                                .foregroundStyle(DesignTokens.Colors.accent)
                                .onSubmit {
                                    saveNickname()
                                }
                        } else {
                            Text(appState.currentUser?.nickname ?? "")
                                .font(DesignTokens.Typography.body)
                                .foregroundStyle(DesignTokens.Colors.secondaryText)
                        }
                        Button {
                            if isEditingNickname {
                                saveNickname()
                            } else {
                                nickname = appState.currentUser?.nickname ?? ""
                                isEditingNickname = true
                            }
                        } label: {
                            Text(isEditingNickname ? "保存" : "編集")
                                .font(DesignTokens.Typography.callout)
                                .foregroundStyle(DesignTokens.Colors.accent)
                        }
                    }
                }

                // Notifications Section
                Section("通知") {
                    Toggle(isOn: $notificationsEnabled) {
                        Text("通知を受け取る")
                            .font(DesignTokens.Typography.body)
                    }
                    .tint(DesignTokens.Colors.accent)

                    Toggle(isOn: $syncTimeNotification) {
                        Text("同期投稿タイムの通知")
                            .font(DesignTokens.Typography.body)
                    }
                    .tint(DesignTokens.Colors.accent)
                    .disabled(!notificationsEnabled)
                }

                // Legal Section
                Section("その他") {
                    Button {
                        // TODO: Open privacy policy URL
                    } label: {
                        HStack {
                            Text("プライバシーポリシー")
                                .font(DesignTokens.Typography.body)
                                .foregroundStyle(DesignTokens.Colors.primaryText)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.Colors.tertiaryText)
                        }
                    }

                    Button {
                        // TODO: Open terms of service URL
                    } label: {
                        HStack {
                            Text("利用規約")
                                .font(DesignTokens.Typography.body)
                                .foregroundStyle(DesignTokens.Colors.primaryText)
                            Spacer()
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(DesignTokens.Colors.tertiaryText)
                        }
                    }
                }

                // Sign Out Section
                Section {
                    Button {
                        showSignOutConfirm = true
                    } label: {
                        Text("ログアウト")
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(DesignTokens.Colors.destructive)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog(
            "ログアウトしますか？",
            isPresented: $showSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button("ログアウト", role: .destructive) {
                appState.signOut()
            }
            Button("キャンセル", role: .cancel) {}
        }
    }

    private func saveNickname() {
        let trimmed = nickname.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isEditingNickname = false
        Task {
            if APIConfig.resolveIsConfigured() {
                let repo = LiveProfileRepository()
                if let updated = try? await repo.updateNickname(trimmed) {
                    appState.currentUser = updated
                    if let data = try? JSONEncoder().encode(updated) {
                        UserDefaults.standard.set(data, forKey: "current_user")
                    }
                }
            } else {
                // Update locally in mock mode
                if var user = appState.currentUser {
                    user = FeemoUser(id: user.id, nickname: trimmed, iconColor: user.iconColor, createdAt: user.createdAt)
                    appState.currentUser = user
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(AppState())
            .environment(AuthManager())
    }
}
