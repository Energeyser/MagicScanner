//
//  ViewController.swift
//  MagicScanner
//
//  Created by axel on 06/11/2018.
//  Copyright © 2018 axel. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/GameScene.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        guard let trackedImages = ARReferenceImage.referenceImages(inGroupNamed: "MagicCards", bundle: Bundle.main) else {
            print("No images availabe")
            return
        }
        
        configuration.trackingImages = trackedImages
        configuration.maximumNumberOfTrackedImages = 2

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        
        let node = SCNNode()
        
        if let imageAnchor = anchor as? ARImageAnchor{
            
            
            
            
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi/2
            
            
            
            let names = ["breath_of_fury", "graven_dominator"]
            for name in names {
                if imageAnchor.referenceImage.name?.range(of: name) != nil {
                    let image = UIImage(named: name)
                    plane.firstMaterial?.diffuse.contents = image
                    
                    let textNode = createTextNode(string: name)
                    textNode.position = SCNVector3Zero
                    var minVec = SCNVector3Zero
                    var maxVec = SCNVector3Zero
                    (minVec, maxVec) =  textNode.boundingBox
                    textNode.pivot = SCNMatrix4MakeTranslation(
                        minVec.x + (maxVec.x - minVec.x)/2,
                        minVec.y,
                        minVec.z + (maxVec.z - minVec.z)/2
                    )
                    textNode.position.z =  Float(-1*imageAnchor.referenceImage.physicalSize.width/2 - 0.02)
                    textNode.eulerAngles.x = -.pi/2
                    node.addChildNode(textNode)
                }
            }
            
           
           


           /*let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
            let shipNode = shipScene.rootNode.childNodes.first!
            shipNode.position = SCNVector3Zero
            shipNode.position.z = 1
            shipNode.eulerAngles.x = .pi/2
            
            planeNode.addChildNode(shipNode)*/

            
            node.addChildNode(planeNode)
        }
        

        
        return node
    }
    
    func createTextNode(string: String) -> SCNNode {
        let text = SCNText(string: string, extrusionDepth: 0.1)
        text.font = UIFont.systemFont(ofSize: 1.0)
        text.flatness = 0.01
        text.firstMaterial?.diffuse.contents = UIColor.white
        
        let textNode = SCNNode(geometry: text)
        
        let fontSize = Float(0.01)
        textNode.scale = SCNVector3(fontSize, fontSize, fontSize)
        
        return textNode
    }
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
