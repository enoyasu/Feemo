import Foundation

struct FeemoUser: Identifiable, Codable {
    let id: String
    var nickname: String
    var iconColor: String
    let createdAt: Date
}

extension FeemoUser {
    static let mockCurrentUser = FeemoUser(
        id: "u1",
        nickname: "あなた",
        iconColor: "A8D8C0",
        createdAt: Date().addingTimeInterval(-86400 * 7)
    )
}
