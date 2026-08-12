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

            Text("Something went wrong")
                .font(.errorTitle)

            Text(message)
                .font(.errorSubtitle)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.large)

            Button("Try Again", action: retryAction)
                .buttonStyle(.borderedProminent)
                .accessibilityLabel("Retry loading listings")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.medium)
    }
}

#Preview {
    ErrorView(message: "The server returned an error (status code: 500).") {}
}
