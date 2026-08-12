import SwiftUI

/// Shared image component used on both list rows and detail screen.
/// Handles three cases uniformly: no URL, loading, and failed load.
struct ListingImageView: View {
    let url: URL?
    let size: CGSize

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure, .empty:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
        .accessibilityHidden(true) // decorative — title and price convey listing identity
    }

    private var placeholder: some View {
        Color.placeholderBackground
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(.tertiary)
                    .font(.title2)
            }
    }
}

#Preview {
    HStack {
        ListingImageView(url: nil, size: ImageSize.rowThumb)
        ListingImageView(url: URL(string: "https://invalid.url/image.jpg"), size: ImageSize.rowThumb)
    }
    .padding()
}
