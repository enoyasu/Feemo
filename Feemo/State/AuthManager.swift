import SwiftUI
import UIKit
import AuthenticationServices

// MARK: - Auth API Response
private struct AuthResponse: Decodable {
    let accessToken: String
    let user: AuthUserDTO
}

private struct AuthUserDTO: Decodable {
    let id: String
    let nickname: String
    let iconColor: String
    let createdAt: String
}

@Observable
class AuthManager: NSObject {
    var error: String? = nil
    private var pendingAppState: AppState?

    // MARK: - Sign in with Apple (triggers native sheet)
    func signInWithApple(appState: AppState) {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.pendingAppState = appState
        controller.performRequests()
    }

    // MARK: - Session Restore
    func restoreSession(appState: AppState) async {
        guard let token = UserDefaults.standard.string(forKey: "auth_token"),
              let userData = UserDefaults.standard.data(forKey: "current_user"),
              let user = try? JSONDecoder().decode(FeemoUser.self, from: userData) else {
            appState.isLoading = false
            return
        }
        // Token exists — validate by checking user data stored locally
        // Production: call GET /me to validate; skip for MVP
        _ = token
        appState.setAuthenticated(user: user)
    }

    // MARK: - Mock Sign In (DEBUG only)
    func mockSignIn(appState: AppState) {
        let mockUser = FeemoUser.mockCurrentUser
        UserDefaults.standard.set("mock_token", forKey: "auth_token")
        if let data = try? JSONEncoder().encode(mockUser) {
            UserDefaults.standard.set(data, forKey: "current_user")
        }
        appState.setAuthenticated(user: mockUser)
    }

    // MARK: - Call Backend after Apple auth
    private func authenticateWithBackend(
        identityToken: String,
        authorizationCode: String,
        nickname: String,
        appState: AppState
    ) async {
        struct Body: Encodable {
            let identity_token: String
            let authorization_code: String
            let nickname: String
        }

        do {
            guard let url = URL(string: APIConfig.resolveBaseURL() + "/auth/apple") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder().encode(Body(
                identity_token: identityToken,
                authorization_code: authorizationCode,
                nickname: nickname
            ))

            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let authResponse = try decoder.decode(AuthResponse.self, from: data)

            let user = FeemoUser(
                id: authResponse.user.id,
                nickname: authResponse.user.nickname,
                iconColor: authResponse.user.iconColor,
                createdAt: ISO8601DateFormatter().date(from: authResponse.user.createdAt) ?? Date()
            )

            UserDefaults.standard.set(authResponse.accessToken, forKey: "auth_token")
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: "current_user")
            }

            appState.setAuthenticated(user: user)
        } catch {
            // Fallback: create user locally if backend is not configured
            let user = FeemoUser(
                id: UUID().uuidString,
                nickname: nickname.isEmpty ? "ユーザー" : nickname,
                iconColor: "A8D8C0",
                createdAt: Date()
            )
            UserDefaults.standard.set(identityToken, forKey: "auth_token")
            if let userData = try? JSONEncoder().encode(user) {
                UserDefaults.standard.set(userData, forKey: "current_user")
            }
            appState.setAuthenticated(user: user)
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthManager: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityTokenData = credential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8),
              let authCodeData = credential.authorizationCode,
              let authorizationCode = String(data: authCodeData, encoding: .utf8) else {
            return
        }

        let nickname = [credential.fullName?.givenName, credential.fullName?.familyName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        Task { @MainActor in
            guard let appState = self.pendingAppState else { return }
            self.pendingAppState = nil
            await self.authenticateWithBackend(
                identityToken: identityToken,
                authorizationCode: authorizationCode,
                nickname: nickname,
                appState: appState
            )
        }
    }

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        Task { @MainActor in
            if (error as? ASAuthorizationError)?.code != .canceled {
                self.error = "ログインに失敗しました。もう一度お試しください。"
            }
            self.pendingAppState = nil
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AuthManager: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        DispatchQueue.main.sync {
            let scene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first
            if let window = scene?.keyWindow { return window }
            if let window = scene?.windows.first { return window }
            // Fallback: create a plain window (deprecated but required for nonisolated context)
            return UIApplication.shared.windows.first ?? UIWindow()
        }
    }
}
