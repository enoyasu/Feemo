import SwiftUI

struct LaunchView: View {
    @Environment(AppState.self) private var appState
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        ZStack {
            DesignTokens.Colors.background
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.md) {
                Image("AppIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .cornerRadius(18)

                Text("Feemo")
                    .font(DesignTokens.Typography.largeTitle)
                    .foregroundStyle(DesignTokens.Colors.primaryText)
            }
        }
        .task {
            await authManager.restoreSession(appState: appState)
        }
    }
}

#Preview {
    LaunchView()
        .environment(AppState())
        .environment(AuthManager())
}
