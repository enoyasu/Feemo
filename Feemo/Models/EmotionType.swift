import SwiftUI

enum EmotionType: String, CaseIterable, Codable, Identifiable {
    case happy = "うれしい"
    case calm = "しずか"
    case anxious = "そわそわ"
    case sleepy = "ねむい"
    case impatient = "焦り"
    case void = "虚無"
    case recovering = "回復中"
    case overwhelmed = "むり"
    case fulfilled = "満たされ"
    case lonely = "さみしい"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .happy: return Color.fromHex("F9C784")
        case .calm: return Color.fromHex("A8C8E8")
        case .anxious: return Color.fromHex("F4A96A")
        case .sleepy: return Color.fromHex("C3B1D8")
        case .impatient: return Color.fromHex("E8B86D")
        case .void: return Color.fromHex("B0B8C1")
        case .recovering: return Color.fromHex("A8D8C0")
        case .overwhelmed: return Color.fromHex("E8A0A0")
        case .fulfilled: return Color.fromHex("9BC89B")
        case .lonely: return Color.fromHex("9EB8D8")
        }
    }

    var lightColor: Color {
        color.opacity(0.25)
    }
}

enum ReactionType: String, CaseIterable, Codable, Identifiable {
    case wakaru = "wakaru"
    case gyu = "gyu"
    case erai = "erai"
    case mimamoru = "mimamoru"
    case shindosou = "shindosou"
    case ureshii = "ureshii"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .wakaru: return "わかる"
        case .gyu: return "ぎゅ"
        case .erai: return "えらい"
        case .mimamoru: return "みまもる"
        case .shindosou: return "しんどそう"
        case .ureshii: return "うれしい"
        }
    }
}

enum VisibilityScope: String, Codable {
    case closeFriends = "close_friends"
    case group = "group"
    case `private` = "private"

    var label: String {
        switch self {
        case .closeFriends: return "親しい友達"
        case .group: return "グループ"
        case .private: return "自分だけ"
        }
    }
}
