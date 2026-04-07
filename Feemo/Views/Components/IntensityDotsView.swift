import SwiftUI

struct IntensityDotsView: View {
    let intensity: Int
    let color: Color
    var size: CGFloat = 7

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { level in
                Circle()
                    .fill(level <= intensity ? color : color.opacity(0.2))
                    .frame(width: size, height: size)
            }
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        IntensityDotsView(intensity: 1, color: .blue)
        IntensityDotsView(intensity: 3, color: .orange)
        IntensityDotsView(intensity: 5, color: .red)
    }
    .padding()
}
