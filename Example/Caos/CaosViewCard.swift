import SwiftUI
import Caos

@available(iOS 16.0, *)
struct CaosViewCard: CaosSwiftUIView {
    let props: CaosProps
    @Environment(\.caosStore) private var store
    @Environment(\.caosTapAction) private var onTap

    var body: some View {
        let balance: String = store.resolve(key: "balance") ?? "—"

        RoundedRectangle(cornerRadius: max(CGFloat(props.double("cornerRadius")), 15))
            .fill(cardBackground)
            .shadow(color: .black.opacity(0.25), radius: 4, x: 4, y: 4)
            .frame(height: 120)
            .overlay(
                HStack(spacing: 16) {
                    Image(systemName: props.string("iconName") ?? "dollarsign.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50, height: 50)
                        .foregroundColor(iconColor)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(props.string("title") ?? "")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.primary)
                        Text(props.string("valueLabel") ?? "")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.secondary)
                        Text(balance)
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
            )
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .onTapGesture { onTap("card_tap", [:]) }
    }

    private var cardBackground: Color {
        colorFromHex(props.hexColor("backgroundColor")) ?? .white
    }

    private var iconColor: Color {
        colorFromHex(props.hexColor("iconColor")) ?? Color(red: 0.102, green: 0.200, blue: 0.400)
    }
}

private func colorFromHex(_ hex: String?) -> Color? {
    guard let hex else { return nil }
    let cleaned = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
    guard cleaned.count == 6, let value = UInt64(cleaned, radix: 16) else { return nil }
    return Color(
        red: Double((value >> 16) & 0xFF) / 255,
        green: Double((value >> 8) & 0xFF) / 255,
        blue: Double(value & 0xFF) / 255
    )
}
