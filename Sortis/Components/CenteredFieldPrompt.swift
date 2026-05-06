import SwiftUI

private struct CenteredFieldPromptModifier: ViewModifier {
    let placeholder: String
    let isEmpty: Bool

    func body(content: Content) -> some View {
        content
            .multilineTextAlignment(.center)
            .overlay(alignment: .center) {
            if isEmpty {
                Text(placeholder)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .allowsHitTesting(false)
                    .padding(.horizontal, 4)
            }
        }
    }
}

extension View {
    func sortisCenteredPlaceholder(_ placeholder: String, isEmpty: Bool) -> some View {
        modifier(CenteredFieldPromptModifier(placeholder: placeholder, isEmpty: isEmpty))
    }
}
