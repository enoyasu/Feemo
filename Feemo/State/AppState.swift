import SwiftUI

@Observable
class AppState {
    var isAuthenticated: Bool = false
    var currentUser: FeemoUser? = nil
    var isLoading: Bool = true

    func setAuthenticated(user: FeemoUser) {
        currentUser = user
        isAuthenticated = true
        isLoading = false
    }

    func signOut() {
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: "auth_token")
        UserDefaults.standard.removeObject(forKey: "current_user")
    }
}
