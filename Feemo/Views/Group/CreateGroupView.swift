import SwiftUI

struct CreateGroupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var groupName = ""
    @State private var isCreating = false
    let onCreated: (String) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.Colors.background
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        Text("グループ名")
                            .font(DesignTokens.Typography.headline)
                            .foregroundStyle(DesignTokens.Colors.primaryText)

                        TextField("例：大学の友達", text: $groupName)
                            .font(DesignTokens.Typography.body)
                            .padding(DesignTokens.Spacing.md)
                            .background(DesignTokens.Colors.surface)
                            .cornerRadius(DesignTokens.Radius.medium)
                    }

                    Text("グループを作ったあとで、メンバーを招待できます（近日公開）")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Colors.tertiaryText)

                    Spacer()

                    Button {
                        guard !groupName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        isCreating = true
                        onCreated(groupName)
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            if isCreating {
                                ProgressView().tint(.white)
                            } else {
                                Text("作成する")
                                    .font(DesignTokens.Typography.headline)
                                    .foregroundStyle(.white)
                            }
                            Spacer()
                        }
                        .frame(height: 50)
                        .background(
                            groupName.trimmingCharacters(in: .whitespaces).isEmpty
                                ? DesignTokens.Colors.border
                                : DesignTokens.Colors.accent
                        )
                        .cornerRadius(DesignTokens.Radius.large)
                    }
                    .disabled(groupName.trimmingCharacters(in: .whitespaces).isEmpty || isCreating)
                }
                .padding(DesignTokens.Spacing.lg)
            }
            .navigationTitle("グループを作る")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                    .foregroundStyle(DesignTokens.Colors.secondaryText)
                }
            }
        }
    }
}

#Preview {
    CreateGroupView { _ in }
}
