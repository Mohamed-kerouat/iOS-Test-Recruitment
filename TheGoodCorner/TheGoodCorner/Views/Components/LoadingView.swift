import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: Spacing.medium) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.accentColor)

            Text(L10n.loadingListingsMessage)
                .font(.emptyStateSubtitle)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(L10n.loadingListingsAccessibility)
    }
}

#Preview {
    LoadingView()
}
