import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: Spacing.medium) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.accentColor)

            Text("Loading listings…")
                .font(.emptyStateSubtitle)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Loading listings, please wait")
    }
}

#Preview {
    LoadingView()
}
