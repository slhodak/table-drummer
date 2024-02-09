import RealityKit

// Ensure you register this component in your app’s delegate using:
// IdentifierComponent.registerComponent()
public struct IdentifierComponent: Component, Codable {
    public var sharedId: String? = nil
    
    public init() {
    }
}
