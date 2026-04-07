import SwiftUI
import UIKit

// MARK: - Color from Hex (brand colors only)
extension Color {
    static func fromHex(_ hex: String) -> Color {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        return Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Design Tokens
enum DesignTokens {
    enum Colors {
        // ── Adaptive (Light / Dark mode 自動対応) ──
        /// アプリ全体の背景
        static let background = Color(UIColor.systemGroupedBackground)
        /// カード・シート背景
        static let surface = Color(UIColor.secondarySystemGroupedBackground)
        /// セカンダリ背景（チップ等）
        static let surfaceSecondary = Color(UIColor.tertiarySystemGroupedBackground)
        /// 主テキスト
        static let primaryText = Color(UIColor.label)
        /// 補助テキスト
        static let secondaryText = Color(UIColor.secondaryLabel)
        /// 第三テキスト（時刻・ラベル等）
        static let tertiaryText = Color(UIColor.tertiaryLabel)
        /// 区切り線・ボーダー
        static let border = Color(UIColor.separator)

        // ── Brand colors (ライト/ダーク共通のブランドカラー) ──
        /// メインアクセント（くすみラベンダー）
        static let accent = Color.fromHex("B5A8D8")
        /// アクセントの薄背景（ライト: 薄ラベンダー / ダーク: 深ラベンダー）
        static let accentSoft = Color(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(red: 0.18, green: 0.16, blue: 0.26, alpha: 1.0)
                : UIColor(red: 0.918, green: 0.902, blue: 0.957, alpha: 1.0)
        })
        /// エラー・削除
        static let destructive = Color(UIColor.systemRed)
    }

    enum Radius {
        static let small: CGFloat = 10
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
        static let extraLarge: CGFloat = 32
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Typography {
        static let largeTitle = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let headline = Font.system(size: 16, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 15, weight: .regular, design: .rounded)
        static let callout = Font.system(size: 14, weight: .regular, design: .rounded)
        static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
        static let small = Font.system(size: 11, weight: .medium, design: .rounded)
    }
}

// MARK: - Card Style
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(DesignTokens.Colors.surface)
            .cornerRadius(DesignTokens.Radius.large)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}
