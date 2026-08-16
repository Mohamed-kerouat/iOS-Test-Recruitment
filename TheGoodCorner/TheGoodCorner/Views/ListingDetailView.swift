import SwiftUI

struct ListingDetailView: View {
    let listing: Listing
    let categories: [Category]

    @Environment(\.apiBaseURL) private var baseURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.medium) {
                ListingImageView(
                    url: listing.thumbImageURL(baseURL: baseURL),
                    size: CGSize(width: ImageSize.detailHero, height: ImageSize.detailHero)
                )
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: Spacing.small) {
                    HStack(alignment: .firstTextBaseline, spacing: Spacing.xSmall) {
                        Text(listing.formattedPrice)
                            .font(.title2.weight(.bold))

                        if listing.isUrgent {
                            detailUrgentBadge
                        }
                    }

                    Text(listing.title)
                        .font(.title3.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)

                    Label(categoryName, systemImage: "tag")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel(L10n.categoryPrefix(categoryName))

                    Label(L10n.publishedOn(listing.formattedCreationDate), systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel(L10n.publishedOn(listing.formattedCreationDate))
                }

                Divider()

                Text(L10n.descriptionSectionTitle)
                    .font(.headline)

                Text(listing.description)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(Spacing.medium)
        }
        .navigationTitle(listing.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var detailUrgentBadge: some View {
        HStack(spacing: Spacing.xxSmall) {
            Image(systemName: "bolt.fill")
            Text(L10n.urgentBadge)
                .font(.caption.weight(.semibold))
        }
        .padding(.horizontal, Spacing.small)
        .padding(.vertical, Spacing.xxSmall)
        .foregroundStyle(Color.urgentAccent)
        .background(Color.urgentAccent.opacity(0.12))
        .clipShape(Capsule())
        .accessibilityLabel(L10n.urgentListingAccessibility)
    }

    private var categoryName: String {
        categories.first { $0.id == listing.categoryID }?.name ?? L10n.unknownCategory
    }
}

#Preview {
    NavigationStack {
        ListingDetailView(
            listing: Listing(
                id: 1,
                isUrgent: true,
                imagesURL: .init(small: nil, thumb: nil),
                creationDate: "2019-11-06T11:22:35Z",
                price: 99,
                description: "A full listing description for preview.",
                categoryID: 3,
                title: "Preview Listing"
            ),
            categories: [Category(id: 3, name: "Home")]
        )
    }
}
