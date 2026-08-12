import SwiftUI

struct EmptyStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: "tray.fill")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text("No listings found")
                .font(.emptyStateTitle)

            Text(message)
                .font(.emptyStateSubtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.medium)
    }
}

#Preview {
    EmptyStateView(message: "Try selecting a different category.")
}
