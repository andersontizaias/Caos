import SwiftUI
import Caos

private let navy = Color(red: 0.102, green: 0.200, blue: 0.400)

@available(iOS 16.0, *)
struct CaosViewShortcuts: CaosSwiftUIView {
    let props: CaosProps
    @Environment(\.caosTapAction) private var onTap

    private let items: [(label: String, icon: String, id: String)] = [
        ("Cancellation", "iphone.gen3.slash.circle", "cancelamento"),
        ("Payment Link", "link.circle",              "payment_link"),
        ("Sales",        "checkmark.circle",         "sales"),
        ("Receivables",  "flag.checkered.circle",    "receivables"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = props.string("title") {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                    shortcutCard(label: item.label, icon: item.icon, id: item.id)
                }
            }
            .padding(.horizontal, 10)
        }
        .padding(.top, 16)
    }

    private func shortcutCard(label: String, icon: String, id: String) -> some View {
        Button { onTap(id, [:]) } label: {
            VStack(spacing: 8) {
                Text(label)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(navy)
                    .multilineTextAlignment(.center)
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .foregroundColor(navy)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 140)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 4, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .strokeBorder(navy.opacity(0.3), lineWidth: 0.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
