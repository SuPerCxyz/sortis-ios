import SwiftUI

struct TokenEntityDetailView: View {
    let token: ApiToken
    let receivers: [Receiver]

    var body: some View {
        TokenDetailView(token: token, receivers: receivers)
    }
}
