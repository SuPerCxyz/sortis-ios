import SwiftUI

struct TokenEntityCard: View {
    let token: ApiToken
    let receivers: [Receiver]

    var body: some View {
        TokenCard(token: token, receivers: receivers)
    }
}
