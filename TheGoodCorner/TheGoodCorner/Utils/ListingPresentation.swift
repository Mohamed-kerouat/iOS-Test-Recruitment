import Foundation

extension Listing {
    var formattedPrice: String {
        "\(price.formatted(.number)) €"
    }

    var formattedCreationDate: String {
        guard let date = Self.apiDateFormatter.date(from: creationDate) else {
            return creationDate
        }

        return Self.displayDateFormatter.string(from: date)
    }

    private static let apiDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
