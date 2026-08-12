import SwiftUI

struct ErrorView: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        VStack(spacing: Spacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            Text(L10n.errorTitle)
                .font(.errorTitle)

            Text(message)
                .font(.errorSubtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.large)

            Button(L10n.retryButtonTitle, action: retryAction)
                .buttonStyle(.borderedProminent)
                .accessibilityLabel(L10n.retryLoadingAccessibility)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.medium)
    }
}

#Preview {
    ErrorView(message: L10n.serverError(statusCode: 500)) {}
}
