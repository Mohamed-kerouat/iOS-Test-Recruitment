import SwiftUI

// MARK: - Typography

extension Font {
    static let listingTitle: Font = .headline
    static let listingPrice: Font = .subheadline.weight(.semibold)
    static let listingCategory: Font = .caption
    static let listingDescription: Font = .body
    static let sectionHeader: Font = .title3.weight(.semibold)
    static let emptyStateTitle: Font = .title3.weight(.semibold)
    static let emptyStateSubtitle: Font = .subheadline
    static let errorTitle: Font = .title3.weight(.semibold)
    static let errorSubtitle: Font = .subheadline
}

// MARK: - Colors

extension Color {
    static let urgentAccent: Color = .orange
    static let priceText: Color = .primary
    static let categoryText: Color = .secondary
    static let placeholderBackground: Color = Color(.secondarySystemBackground)
}

// MARK: - Spacing

enum Spacing {
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat = 8
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
}

// MARK: - Image dimensions

enum ImageSize {
    static let rowThumb = CGSize(width: 80, height: 80)
    static let detailHero: CGFloat = 300
}

// MARK: - Corner radius

enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
}
