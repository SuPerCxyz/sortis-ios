import SwiftUI

struct ReceiverEntityDetailView: View {
    let receiver: Receiver
    let boundTokenName: String?

    var body: some View {
        ReceiverDetailView(
            receiver: receiver,
            boundTokenName: boundTokenName
        )
    }
}
