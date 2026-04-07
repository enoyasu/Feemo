import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo + Tagline
                VStack(spacing: DesignTokens.Spacing.lg) {
                    Image("AppIcon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .cornerRadius(24)
                        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 4)

                    VStack(spacing: DesignTokens.Spacing.sm) {
                        Text("Feemo")
                            .font(DesignTokens.Typography.largeTitle)
                            .foregroundStyle(DesignTokens.Colors.primaryText)

                        Text("今の感情を、ひと粒だけ置く")
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(DesignTokens.Colors.secondaryText)
                    }
                }

                Spacer()
                Spacer()

                // Sign In Section
                VStack(spacing: DesignTokens.Spacing.md) {
                    if let error = authManager.error {
                        Text(error)
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.destructive)
                            .multilineTextAlignment(.center)
                    }

                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        // Handled by AuthManager delegate
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(DesignTokens.Radius.medium)

                    // Mock sign in for development
                    #if DEBUG
                    Button {
                        authManager.mockSignIn(appState: appState)
                    } label: {
                        Text("開発用：スキップ")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.tertiaryText)
                    }
                    #endif

                    // Terms
                    VStack(spacing: 2) {
                        Text("続けることで")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Colors.tertiaryText)
                        HStack(spacing: 4) {
                            Text("利用規約")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(DesignTokens.Colors.accent)
                            Text("と")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(DesignTokens.Colors.tertiaryText)
                            Text("プライバシーポリシー")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(DesignTokens.Colors.accent)
                            Text("に同意します")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(DesignTokens.Colors.tertiaryText)
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.xl)
                .padding(.bottom, DesignTokens.Spacing.xxl)
            }
        }
    }
}

#Preview {
    AuthView()
        .environment(AppState())
        .environment(AuthManager())
}
