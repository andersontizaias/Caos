import SwiftUI
import Caos

private let navy = Color(red: 0.102, green: 0.200, blue: 0.400)

@available(iOS 16.0, *)
struct CaosViewShortcutsChain: CaosSwiftUIView {
    let props: CaosProps
    @Environment(\.caosTapAction) private var onTap

    private let items: [(label: String, icon: String, id: String)] = [
        ("Simulator", "iphone.gen3.circle",            "simulator"),
        ("Pix",       "arrow.left.arrow.right.circle", "pix"),
        ("Advance",   "dollarsign.circle",             "antecipacao"),
        ("Cancel",    "iphone.gen3.slash.circle",      "cancelamento"),
    ]

    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.25), radius: 4, x: 4, y: 4)
            .frame(height: 110)
            .overlay(
                VStack(alignment: .leading, spacing: 6) {
                    if let title = props.string("title") {
                        Text(title)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    HStack(spacing: 4) {
                        ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                            quickActionButton(label: item.label, icon: item.icon, id: item.id)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
            )
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
    }

    private func quickActionButton(label: String, icon: String, id: String) -> some View {
        Button { onTap(id, [:]) } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .foregroundColor(navy)
                Text(label)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(navy)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
