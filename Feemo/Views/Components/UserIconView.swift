import SwiftUI

struct UserIconView: View {
    let nickname: String
    let colorHex: String
    var size: CGFloat = 36

    private var initial: String {
        String(nickname.prefix(1))
    }

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.fromHex(colorHex).opacity(0.4))
                .frame(width: size, height: size)
            Text(initial)
                .font(.system(size: size * 0.4, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.fromHex(colorHex))
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        UserIconView(nickname: "みお", colorHex: "A8C8E8")
        UserIconView(nickname: "りく", colorHex: "E8A0A0")
        UserIconView(nickname: "はるか", colorHex: "F9C784")
    }
    .padding()
}
