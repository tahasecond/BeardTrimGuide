import SwiftUI
import ARKit

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        
        guard ARFaceTrackingConfiguration.isSupported else { fatalError("Face tracking not supported on this device") }
        sceneView.delegate = context.coordinator
        
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        // Specific indices for the beard line vertices
        let beardLineIndices = [376, 208, 904, 462, 392, 920, 918, 916, 914, 1047, 913, 912, 911, 910, 909, 908, 907, 906, 822, 1216, 1215, 1214, 1213, 730, 807, 966]

        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard let device = renderer.device else { return nil }
            guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
            
            let faceGeometry = ARSCNFaceGeometry(device: device)
            let node = SCNNode(geometry: faceGeometry)
            
            node.geometry?.firstMaterial?.fillMode = .lines
            
            // Add labels only for the specified beard line vertices
            for index in beardLineIndices {
                let text = SCNText(string: "\(index)", extrusionDepth: 1)
                let textNode = SCNNode(geometry: text)
                textNode.scale = SCNVector3(x: 0.00025, y: 0.00025, z: 0.00025)
                textNode.name = "\(index)"
                
                // Set the text color to distinguish the beard line
                textNode.geometry?.firstMaterial?.diffuse.contents = UIColor.green
                
                // Position the text node at the corresponding vertex
                let vertex = SCNVector3(faceAnchor.geometry.vertices[index])
                textNode.position = vertex
                
                node.addChildNode(textNode)
            }
            
            return node
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor,
                  let faceGeometry = node.geometry as? ARSCNFaceGeometry
            else { return }
            
            faceGeometry.update(from: faceAnchor.geometry)
        
            // Update positions of beard line text nodes
            for index in beardLineIndices {
                let textNode = node.childNode(withName: "\(index)", recursively: false)
                let vertex = SCNVector3(faceAnchor.geometry.vertices[index])
                textNode?.position = vertex
            }
        }
    }
}
#Preview {
    ContentView()
}
