import SwiftUI

struct PostComposerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PostComposerViewModel

    init(postRepo: any PostRepositoryProtocol) {
        _viewModel = State(initialValue: PostComposerViewModel(postRepo: postRepo))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignTokens.Colors.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                        // Emotion Selection
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                            Text("いまの気分")
                                .font(DesignTokens.Typography.headline)
                                .foregroundStyle(DesignTokens.Colors.primaryText)

                            emotionGrid
                        }

                        // Intensity Slider
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                            HStack {
                                Text("強さ")
                                    .font(DesignTokens.Typography.headline)
                                    .foregroundStyle(DesignTokens.Colors.primaryText)
                                Spacer()
                                IntensityDotsView(
                                    intensity: Int(viewModel.intensity),
                                    color: viewModel.selectedEmotion?.color ?? DesignTokens.Colors.accent,
                                    size: 9
                                )
                            }

                            Slider(value: $viewModel.intensity, in: 1...5, step: 1)
                                .tint(viewModel.selectedEmotion?.color ?? DesignTokens.Colors.accent)
                        }

                        // Note
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                            Text("一言（任意）")
                                .font(DesignTokens.Typography.headline)
                                .foregroundStyle(DesignTokens.Colors.primaryText)

                            TextField("40文字以内で...", text: $viewModel.shortNote, axis: .vertical)
                                .font(DesignTokens.Typography.body)
                                .padding(DesignTokens.Spacing.md)
                                .background(DesignTokens.Colors.surface)
                                .cornerRadius(DesignTokens.Radius.medium)
                                .onChange(of: viewModel.shortNote) {
                                    if viewModel.shortNote.count > 40 {
                                        viewModel.shortNote = String(viewModel.shortNote.prefix(40))
                                    }
                                }

                            HStack {
                                Spacer()
                                Text("\(viewModel.shortNote.count)/40")
                                    .font(DesignTokens.Typography.caption)
                                    .foregroundStyle(DesignTokens.Colors.tertiaryText)
                            }
                        }

                        // Visibility Scope
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                            Text("投稿先")
                                .font(DesignTokens.Typography.headline)
                                .foregroundStyle(DesignTokens.Colors.primaryText)

                            HStack(spacing: DesignTokens.Spacing.sm) {
                                ForEach([VisibilityScope.closeFriends, .private], id: \.self) { scope in
                                    Button {
                                        viewModel.selectedScope = scope
                                    } label: {
                                        Text(scope.label)
                                            .font(DesignTokens.Typography.callout)
                                            .foregroundStyle(
                                                viewModel.selectedScope == scope
                                                    ? DesignTokens.Colors.accent
                                                    : DesignTokens.Colors.secondaryText
                                            )
                                            .padding(.horizontal, DesignTokens.Spacing.md)
                                            .padding(.vertical, DesignTokens.Spacing.sm)
                                            .background(
                                                viewModel.selectedScope == scope
                                                    ? DesignTokens.Colors.accentSoft
                                                    : DesignTokens.Colors.surface
                                            )
                                            .cornerRadius(DesignTokens.Radius.extraLarge)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Error
                        if let error = viewModel.errorMessage {
                            Text(error)
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(DesignTokens.Colors.destructive)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }

                        // Submit Button
                        Button {
                            Task { await viewModel.submit() }
                        } label: {
                            HStack {
                                Spacer()
                                if viewModel.isSubmitting {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("置く")
                                        .font(DesignTokens.Typography.headline)
                                        .foregroundStyle(.white)
                                }
                                Spacer()
                            }
                            .frame(height: 50)
                            .background(
                                viewModel.canSubmit
                                    ? (viewModel.selectedEmotion?.color ?? DesignTokens.Colors.accent)
                                    : DesignTokens.Colors.border
                            )
                            .cornerRadius(DesignTokens.Radius.large)
                        }
                        .disabled(!viewModel.canSubmit)
                        .animation(.easeInOut(duration: 0.2), value: viewModel.selectedEmotion)
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
            }
            .navigationTitle("気分を置く")
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
        .onChange(of: viewModel.didSucceed) {
            if viewModel.didSucceed {
                dismiss()
            }
        }
    }

    private var emotionGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: DesignTokens.Spacing.sm), count: 3),
            spacing: DesignTokens.Spacing.sm
        ) {
            ForEach(EmotionType.allCases) { emotion in
                EmotionChipButton(
                    emotion: emotion,
                    isSelected: viewModel.selectedEmotion == emotion
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if viewModel.selectedEmotion == emotion {
                            viewModel.selectedEmotion = nil
                        } else {
                            viewModel.selectedEmotion = emotion
                        }
                    }
                }
            }
        }
    }
}

struct EmotionChipButton: View {
    let emotion: EmotionType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(emotion.rawValue)
                .font(DesignTokens.Typography.callout)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? emotion.color : DesignTokens.Colors.secondaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(
                    isSelected
                        ? emotion.lightColor
                        : DesignTokens.Colors.surface
                )
                .cornerRadius(DesignTokens.Radius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.medium)
                        .stroke(
                            isSelected ? emotion.color.opacity(0.4) : DesignTokens.Colors.border,
                            lineWidth: 1
                        )
                )
                .scaleEffect(isSelected ? 1.03 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    PostComposerSheet(postRepo: MockPostRepository())
}
