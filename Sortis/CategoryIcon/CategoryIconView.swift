//
//  CategoryIconView.swift
//  Sortis
//

import SwiftUI

struct CategoryIconView: View {
    let icon: String?
    let iconUrl: String?
    let size: CGFloat
    let cornerRadius: CGFloat

    init(icon: String?, iconUrl: String?, size: CGFloat = 18, cornerRadius: CGFloat = 4) {
        self.icon = icon
        self.iconUrl = iconUrl
        self.size = size
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        if let iconUrl, let url = URL(string: iconUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                default:
                    fallbackIcon
                }
            }
        } else {
            fallbackIcon
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: categoryIconSymbolName(for: icon))
            .font(.system(size: size, weight: .semibold))
            .foregroundStyle(categoryIconTint(for: icon))
            .frame(width: size, height: size)
    }
}
