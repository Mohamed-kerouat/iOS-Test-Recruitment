import SwiftUI

struct ListingRowView: View {
    let listing: Listing
    let categories: [Category]

    @Environment(\.apiBaseURL) private var baseURL

    var body: some View {
        HStack(alignment: .top, spacing: Spacing.small) {
            ListingImageView(
                url: listing.smallImageURL(baseURL: baseURL),
                size: ImageSize.rowThumb
            )

            VStack(alignment: .leading, spacing: Spacing.xxSmall) {
                HStack(spacing: Spacing.xSmall) {
                    Text(categoryName)
                        .font(.listingCategory)
                        .foregroundStyle(Color.categoryText)

                    if listing.isUrgent {
                        urgentBadge
                    }
                }

                Text(listing.title)
                    .font(.listingTitle)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text(listing.formattedPrice)
                    .font(.listingPrice)
                    .foregroundStyle(Color.priceText)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, Spacing.xxSmall)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    // MARK: - Sub-views

    private var urgentBadge: some View {
        HStack(spacing: Spacing.xxSmall) {
            Image(systemName: "bolt.fill")
                .font(.caption2)
            Text(L10n.urgentBadge)
                .font(.caption2.weight(.semibold))
        }
        .foregroundStyle(Color.urgentAccent)
        // Not hidden: the badge text "Urgent" is meaningful for accessibility
        .accessibilityLabel(L10n.urgentListingAccessibility)
    }

    // MARK: - Helpers

    private var categoryName: String {
        categories.first { $0.id == listing.categoryID }?.name ?? L10n.unknownCategory
    }

    private var accessibilityDescription: String {
        var parts = [listing.title, listing.formattedPrice, categoryName]
        if listing.isUrgent { parts.append(L10n.urgentBadge) }
        return parts.joined(separator: ", ")
    }
}
