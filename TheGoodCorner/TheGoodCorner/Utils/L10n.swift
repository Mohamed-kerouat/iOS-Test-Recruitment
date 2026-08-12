import Foundation

enum L10n {
    static var listingsNavigationTitle: String {
        String(localized: "listings.navigation.title", defaultValue: "Listings")
    }

    static var loadingListingsMessage: String {
        String(localized: "listings.loading.message", defaultValue: "Loading listings...")
    }

    static var loadingListingsAccessibility: String {
        String(localized: "listings.loading.accessibility", defaultValue: "Loading listings, please wait")
    }

    static var errorTitle: String {
        String(localized: "listings.error.title", defaultValue: "Something went wrong")
    }

    static var retryButtonTitle: String {
        String(localized: "listings.error.retry.button", defaultValue: "Try Again")
    }

    static var retryLoadingAccessibility: String {
        String(localized: "listings.error.retry.accessibility", defaultValue: "Retry loading listings")
    }

    static var emptyTitle: String {
        String(localized: "listings.empty.title", defaultValue: "No listings found")
    }

    static var emptyAllListingsMessage: String {
        String(localized: "listings.empty.all.message", defaultValue: "No listings available right now.")
    }

    static var emptyFilteredListingsMessage: String {
        String(localized: "listings.empty.filtered.message", defaultValue: "No listings found in this category.")
    }

    static var emptyPreviewMessage: String {
        String(localized: "listings.empty.preview.message", defaultValue: "Try selecting a different category.")
    }

    static var categoryFilterLabel: String {
        String(localized: "listings.filter.bar.label", defaultValue: "Category filter")
    }

    static var allCategoriesFilterTitle: String {
        String(localized: "listings.filter.all", defaultValue: "All")
    }

    static func selectedFilterAccessibility(_ label: String) -> String {
        let format = String(localized: "listings.filter.selected", defaultValue: "%@, selected")
        return String(format: format, locale: Locale.current, label)
    }

    static func categoryFilterHint(_ label: String) -> String {
        let format = String(localized: "listings.filter.hint", defaultValue: "Filter listings by %@")
        return String(format: format, locale: Locale.current, label)
    }

    static var urgentBadge: String {
        String(localized: "listing.urgent.badge", defaultValue: "Urgent")
    }

    static var urgentListingAccessibility: String {
        String(localized: "listing.urgent.accessibility", defaultValue: "Urgent listing")
    }

    static var unknownCategory: String {
        String(localized: "listing.category.unknown", defaultValue: "Unknown")
    }

    static var listingDetailNavigationTitle: String {
        String(localized: "listing.detail.navigation.title", defaultValue: "Detail")
    }

    static func categoryPrefix(_ categoryName: String) -> String {
        let format = String(localized: "listing.detail.category.label", defaultValue: "Category: %@")
        return String(format: format, locale: Locale.current, categoryName)
    }

    static func publishedOn(_ date: String) -> String {
        let format = String(localized: "listing.detail.publishedOn.label", defaultValue: "Published on %@")
        return String(format: format, locale: Locale.current, date)
    }

    static var descriptionSectionTitle: String {
        String(localized: "listing.detail.description.section", defaultValue: "Description")
    }

    static var genericErrorMessage: String {
        String(localized: "common.error.generic", defaultValue: "Something went wrong. Please try again.")
    }

    static var invalidRequestURLMessage: String {
        String(localized: "api.error.invalidURL", defaultValue: "The request URL could not be created.")
    }

    static var invalidResponseMessage: String {
        String(localized: "api.error.invalidResponse", defaultValue: "The server returned an invalid response.")
    }

    static var emptyResponseMessage: String {
        String(localized: "api.error.emptyData", defaultValue: "The server returned an empty response.")
    }

    static func serverError(statusCode: Int) -> String {
        let format = String(localized: "api.error.server", defaultValue: "The server returned an error (status code: %d).")
        return String(format: format, locale: Locale.current, statusCode)
    }
}
