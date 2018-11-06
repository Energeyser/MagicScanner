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
                    
                    makeGetCall(cardName: name) { (output) in
                        print("pimpampoum " + output)
                        let textNode = self.createTextNode(string: "Valeur : " + output + " €")
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
                        
                        node.addChildNode(planeNode)
                    }
                    
                    let image = UIImage(named: name)
                    plane.firstMaterial?.diffuse.contents = image
                    
                    
                }
            }
            
          

           /*let shipScene = SCNScene(named: "art.scnassets/ship.scn")!
            let shipNode = shipScene.rootNode.childNodes.first!
            shipNode.position = SCNVector3Zero
            shipNode.position.z = 1
            shipNode.eulerAngles.x = .pi/2
            
            planeNode.addChildNode(shipNode)*/
          
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
    
    func makeGetCall(cardName: String, completionBlock: @escaping (String) -> Void) -> Void  {
        // Set up the URL request
        let todoEndpoint: String = "https://api.scryfall.com/cards/named?fuzzy=" + cardName
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        // set up the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        // make the request
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let jsonData = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                //print("The todo is: " + todo.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                let jsonPrice = jsonData["eur"] as? String
                completionBlock(jsonPrice!);
                print(jsonPrice)
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
    
        task.resume()
        return
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
