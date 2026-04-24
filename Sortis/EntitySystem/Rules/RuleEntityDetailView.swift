import SwiftUI

struct RuleEntityDetailView: View {
    let rule: Rule
    let categories: [Category]

    var body: some View {
        RuleDetailView(rule: rule, categories: categories)
    }
}
