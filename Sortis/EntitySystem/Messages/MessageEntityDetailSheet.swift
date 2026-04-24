import SwiftUI

struct MessageEntityDetailSheet: View {
    let message: Message
    let onToggleRead: () -> Void
    let onToggleStar: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        MessageDetailSheet(
            message: message,
            onToggleRead: onToggleRead,
            onToggleStar: onToggleStar,
            onDismiss: onDismiss
        )
    }
}
