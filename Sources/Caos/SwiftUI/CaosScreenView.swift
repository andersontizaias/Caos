import SwiftUI

/// View SwiftUI que carrega e renderiza uma tela Caos a partir de um arquivo YAML.
///
/// Uso:
/// ```swift
/// CaosScreenView(name: "home")
///     .caosStore(store)
///     .onCaosTap { id, context in
///         navigator.push(id)
///     }
/// ```
@available(iOS 16.0, macOS 13.0, *)
public struct CaosScreenView: View {

    private let name: String
    private let bundle: Bundle

    @Environment(\.caosStore) private var store
    @State private var schema: CaosSchema?
    @State private var parseError: CaosError?

    public init(name: String, bundle: Bundle = .main) {
        self.name = name
        self.bundle = bundle
    }

    public var body: some View {
        Group {
            if let schema {
                if let screen = schema.screens.first {
                    CaosContainerView(screen: screen)
                } else {
                    emptyState("Nenhuma tela encontrada no YAML '\(name)'")
                }
            } else if let parseError {
                errorState(parseError)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await loadSchema() }
    }

    // MARK: - Private helpers

    @MainActor
    private func loadSchema() async {
        guard let path = bundle.path(forResource: name, ofType: "yaml") else {
            parseError = .invalidYAML(line: 0, reason: "'\(name).yaml' não encontrado no bundle")
            return
        }
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            schema = try CaosParser.parse(content)
        } catch let caosErr as CaosError {
            parseError = caosErr
        } catch {
            parseError = .invalidYAML(line: 0, reason: error.localizedDescription)
        }
    }

    private func emptyState(_ message: String) -> some View {
        Text(message)
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding()
    }

    private func errorState(_ error: CaosError) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            Text(error.localizedDescription)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}
