//
//  ViewController.swift
//  BallSpinningAroundHead
//
//  Created by Evgeny on 5/15/20.
//  Copyright © 2020 Evgeny. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    var currentFaceAnchor: ARFaceAnchor?
    
    var faceNode: SCNNode?
    var sphereNode: SCNSphere?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
//        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        //sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        resetTracking()
        
        //default code
//        let configuration = ARWorldTrackingConfiguration()
//        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func displayErrorMessage(title: String, message: String) {
        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    func addSphere(to node: SCNNode) {
//        let g = SCNSphere(radius: 5000)
//        g.firstMaterial?.diffuse.contents = UIColor.green
//        let sphereNode = SCNNode(geometry: g)
        //sphereNode.position = SCNVector3(x: 0, y: 0, z: 0)
        
        let shipNode = SCNReferenceNode(named: "coordinateOrigin")
        shipNode.position = SCNVector3(x: 0.1, y: 0.1, z: 0)
        
        let rotatableNode = SCNNode()
        
        let spin = CABasicAnimation(keyPath: "rotation")
        spin.toValue = NSValue(scnVector4: SCNVector4(x: 0, y: 1, z: 0, w: Float(2.0 * Double.pi)))
        spin.duration = 2
        spin.repeatCount = HUGE
        rotatableNode.addAnimation(spin, forKey: "spin")
        
        rotatableNode.addChildNode(shipNode)
        
        node.addChildNode(rotatableNode)
    }
}

extension ViewController : ARSessionDelegate {
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")
        
        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension ViewController : ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        currentFaceAnchor = faceAnchor
        
        faceNode = SCNReferenceNode(named: "coordinateOrigin")
        
        if let faceNode = self.faceNode {
            node.addChildNode(faceNode)
            
            addSphere(to: node)
        }
   }
   
   /// - Tag: ARFaceGeometryUpdate
   func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
       guard anchor == currentFaceAnchor,
           let contentNode = faceNode,
           contentNode.parent == node
           else { return }
   }
}
