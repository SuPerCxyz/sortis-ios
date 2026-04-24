import SwiftUI

struct ReceiverEntityCard: View {
    let receiver: Receiver
    let boundTokenName: String?

    var body: some View {
        ReceiverCard(
            receiver: receiver,
            boundTokenName: boundTokenName
        )
    }
}
