//
//  ViewController+Delegate.swift
//  ARMeasuring
//
//  Created by Nishant Gupta on 25/1/22.
//

import ARKit


extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        guard let startingPosition = startingPosition,
              let pointOfView = self.sceneView.pointOfView else { return }
        let transform = pointOfView.transform
        let location = SCNVector3(transform.m41, transform.m42, transform.m43)
        let xDistance = location.x - startingPosition.position.x
        let yDistance = location.y - startingPosition.position.y
        let zDistance = location.z - startingPosition.position.z
        
        DispatchQueue.main.async {
            self.xLabel.text = String(format: "%.2f", xDistance) + "m"
            self.yLabel.text = String(format: "%.2f", yDistance) + "m"
            self.zLabel.text = String(format: "%.2f", zDistance) + "m"
            self.distance.text = String(format: "%.2f", self.distanceTravelled(x: xDistance, y: yDistance, z: zDistance)) + "m"
            let path = UIBezierPath(ovalIn: CGRect(x: Double(Float(self.startingPoint.x) - (Float(location.x) * 100)), y: Double(Float(self.startingPoint.y) - (Float(location.z) * 100)), width: 5, height: 5))
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = path.cgPath
            shapeLayer.fillColor = UIColor.orange.cgColor
            shapeLayer.lineWidth = 3
            shapeLayer.strokeColor = UIColor.black.cgColor
            self.mapView.layer.addSublayer(shapeLayer)
        }
        // Add next node as soon as z distance i.e. depth from camera frame is less than 0.1
        if zDistance < 0.1, canAddNode, currentNodeCount < nodePlacements.count {
            // set can add node as false to prevent adding all nodes together
            canAddNode = false
            let parentTransform = matrix_float4x4(startingPosition.transform)
            var translationMatrix = matrix_identity_float4x4
            translationMatrix.columns.3.x = nodePlacements[currentNodeCount].position.x
            translationMatrix.columns.3.y = nodePlacements[currentNodeCount].position.y
            translationMatrix.columns.3.z = nodePlacements[currentNodeCount].position.z
            let modifiedMatrix = matrix_multiply(parentTransform, translationMatrix)
            placeNode(position: modifiedMatrix, xAngle: nodePlacements[currentNodeCount].rotationAngles[0], yAngle: nodePlacements[currentNodeCount].rotationAngles[1], zAngle: nodePlacements[currentNodeCount].rotationAngles[2])
            nodePlacements[currentNodeCount].isAdded = true
            currentNodeCount += 1
        }
        // as soon as next node is inside the frustum of camera frame allow for next node to be added 
        if !canAddNode, let previousNode = nodePlacements[currentNodeCount-1].placedNode,
           renderer.isNode(previousNode, insideFrustumOf: renderer.pointOfView!) {
            canAddNode = true
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical, let geom = ARSCNPlaneGeometry(device: MTLCreateSystemDefaultDevice()!) {
            geom.update(from: planeAnchor.geometry)
            geom.firstMaterial?.colorBufferWriteMask = .alpha
            node.geometry = geom
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical, let geom = node.geometry as? ARSCNPlaneGeometry {
            geom.update(from: planeAnchor.geometry)
        }
    }
    
    func distanceTravelled(x: Float, y: Float, z: Float) -> Float {
        return (sqrtf(x*x + y*y + z*z))
    }
    
    func placeNode(position: simd_float4x4, xAngle: Int, yAngle: Int, zAngle: Int) {
        let scene = SCNScene(named: "Arrow.scn")
        let sphere = (scene?.rootNode.childNode(withName: "sphere", recursively: false))!
        //        sphere.transform = SCNMatrix4(position)
        if let startingPoint = self.startingPosition {
            sphere.position = SCNVector3(startingPoint.transform.m41 + nodePlacements[currentNodeCount].position.x,
                                         startingPoint.transform.m42 + nodePlacements[currentNodeCount].position.y,
                                         startingPoint.transform.m43 + nodePlacements[currentNodeCount].position.z)
        }
        sphere.eulerAngles = SCNVector3(xAngle.degreesToRadians,yAngle.degreesToRadians,zAngle.degreesToRadians)
        let parentNode = SCNNode()
        parentNode.addChildNode(sphere)
        self.sceneView.scene.rootNode.addChildNode(sphere)
        if currentNodeCount == nodePlacements.count - 1 {
            let textNode = SCNNode(geometry: SCNText(string: "Gas", extrusionDepth: 0))
            textNode.scale = SCNVector3(0.002, 0.002, 0.002)
            let textParentNode = SCNNode()
            textParentNode.addChildNode(textNode)
            textParentNode.eulerAngles = SCNVector3(90.degreesToRadians, 180.degreesToRadians, 0)
            sphere.addChildNode(textParentNode)
        }
        self.startingPosition = sphere
        nodePlacements[currentNodeCount].placedNode = sphere
        DispatchQueue.main.async {
            self.currentCameralabel.text = "Node placed at \(sphere.position)"
        }
    }
}
