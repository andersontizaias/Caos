import SwiftUI
import XCTest

@testable import Caos

@available(iOS 16.0, macOS 13.0, *)
final class CaosViewRenderingTests: XCTestCase {

    // MARK: - CaosContainerView body

    func test_containerView_vertical_body() {
        _ = CaosContainerView(screen: makeScreen(type: "vertical")).body
    }

    func test_containerView_horizontal_body() {
        _ = CaosContainerView(screen: makeScreen(type: "horizontal")).body
    }

    func test_containerView_grid_body() {
        _ = CaosContainerView(screen: makeScreen(type: "grid")).body
    }

    func test_containerView_withShards_body() {
        let screen = makeScreen(type: "vertical")
        let store = CaosStore()
        store.register(type: "Card", view: StubShardView.self)
        screen.shardList = [
            CaosShard(type: "Card", id: "c1", props: CaosProps(["label": "Hi"])),
            CaosShard(type: "Unknown", id: "c2", props: CaosProps()),
        ]
        _ = CaosContainerView(screen: screen).body
    }

    func test_containerView_withPadding_body() {
        let screen = makeScreen(type: "vertical")
        screen.containerConfig = CaosContainer(
            type: "vertical",
            spacing: 8,
            padding: CaosEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        )
        _ = CaosContainerView(screen: screen).body
    }

    // MARK: - CaosUnknownShardView body

    func test_unknownShardView_body() {
        _ = CaosUnknownShardView(type: "Missing").body
    }

    // MARK: - CaosScreenView body states

    func test_screenView_initialState_body() {
        _ = CaosScreenView(name: "nonexistent").body
    }

    func test_screenView_withScreens_body() throws {
        let yaml = """
        version: 1
        screens:
          - id: home
            container:
              type: vertical
            shards: []
        """
        let schema = try CaosParser.parse(yaml)
        let view = CaosScreenView(name: "t", bundle: .main, preloadedSchema: schema, preloadedError: nil)
        _ = view.body
    }

    func test_screenView_withEmptyScreens_body() throws {
        let schema = try CaosParser.parse("version: 1\nscreens: []\n")
        let view = CaosScreenView(name: "t", bundle: .main, preloadedSchema: schema, preloadedError: nil)
        _ = view.body
    }

    func test_screenView_withParseError_body() {
        let view = CaosScreenView(name: "t", bundle: .main, preloadedSchema: nil, preloadedError: .missingVersion)
        _ = view.body
    }

    // MARK: - CaosScreenView loadSchema

    @MainActor
    func test_screenView_loadSchema_missingFile() async {
        let view = CaosScreenView(name: "nonexistent_xyz_caos")
        await view.loadSchema()
    }

    @MainActor
    func test_screenView_loadSchema_validFile() async {
        // Bundle.module resolves SPM test-target resources correctly
        let view = CaosScreenView(name: "caos_empty_screens", bundle: .module)
        await view.loadSchema()
    }

    @MainActor
    func test_screenView_loadSchema_caosError() async {
        let view = CaosScreenView(name: "caos_invalid_version", bundle: .module)
        await view.loadSchema()
    }

    // MARK: - CaosShimmerModifier

    func test_shimmer_active() {
        _ = Text("test").shimmer(isActive: true)
    }

    func test_shimmer_inactive() {
        _ = Text("test").shimmer(isActive: false)
    }

    func test_shimmerModifier_shimmerOverlay() {
        let modifier = ShimmerModifier(isActive: true)
        _ = modifier.shimmerOverlay
    }

    func test_shimmerModifier_startAnimation() {
        let modifier = ShimmerModifier(isActive: true)
        modifier._startAnimation()
    }

    func test_shimmerModifier_startAnimation_inactive() {
        let modifier = ShimmerModifier(isActive: false)
        modifier._startAnimation()
    }

    // MARK: - CaosEnvironment modifiers

    func test_caosStoreModifier_coversViewExtension() {
        let store = CaosStore()
        _ = EmptyView().caosStore(store)
    }

    // MARK: - CaosTapHandler default action

    func test_tapHandler_defaultValue_executed() {
        let action = EnvironmentValues().caosTapAction
        action("id", [:])
    }

    // MARK: - Helpers

    private func makeScreen(type: String) -> CaosScreen {
        let screen = CaosScreen()
        screen.id = "test_\(type)"
        screen.containerConfig = CaosContainer(type: type, spacing: 8)
        return screen
    }
}

@available(iOS 16.0, macOS 13.0, *)
private struct StubShardView: CaosSwiftUIView {
    let props: CaosProps
    var body: some View {
        Text(props.string("label") ?? "stub")
    }
}
