import SwiftUI

struct MessageEntityCard: View {
    let message: Message
    let action: () -> Void

    var body: some View {
        MessageCard(message: message, action: action)
    }
}
