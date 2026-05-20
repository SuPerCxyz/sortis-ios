import SwiftUI

struct ReceiverEntityDetailView: View {
    let receiver: Receiver
    let boundToken: ApiToken?
    let serverUrl: String?

    var body: some View {
        ReceiverDetailView(
            receiver: receiver,
            boundToken: boundToken,
            serverUrl: serverUrl
        )
    }
}
