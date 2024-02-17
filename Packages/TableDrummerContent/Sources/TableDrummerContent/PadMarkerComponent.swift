import RealityKit

// Ensure you register this component in your app’s delegate using:
// PadMarkerComponent.registerComponent()
public struct PadMarkerComponent: Component, Codable {
    // This is an example of adding a variable to the component.
    var name: String = ""
    
    public init(name: String) {
        self.name = name
    }
}
