//
//  ViewController.swift
//  ARMeasuring
//
//  Created by Nishant Gupta on 23/1/22.
//

import UIKit
import ARKit
import GameplayKit

class ViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var currentCameralabel: UILabel!
    @IBOutlet weak var zLabel: UILabel!
    @IBOutlet weak var yLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var distance: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var mapView: UIView!
    var obstacles: [GKPolygonObstacle] = []
    var obstacleGraph: GKObstacleGraph? = nil
    var resultPath: [CGPoint]? = nil
    let startingPoint = CGPoint(x: 790, y: 85)
    let destination = CGPoint(x: 200, y: 900)
    
    let configuration = ARWorldTrackingConfiguration()
    var startingPosition: SCNNode?
//    var nodePlacements = [PathNode(position: SCNVector3(x: 1.5, y: 0, z: 0), rotationAngles: [-90,0,0], isAdded: false),
//                          PathNode(position: SCNVector3(x: 0, y: 0, z: -2.0), rotationAngles: [0,0,-90], isAdded: false),
//                          PathNode(position: SCNVector3(x: 1.4, y: 0, z: 0), rotationAngles: [90,0,0], isAdded: false),
//                          PathNode(position: SCNVector3(0, 0, 1.8), rotationAngles: [0,0,-90], isAdded: false),
//                          PathNode(position: SCNVector3(x: 2.0, y: 0, z: 0), rotationAngles: [-90,0,0], isAdded: false),
//                          PathNode(position: SCNVector3(x: 0, y: 0, z: -6), rotationAngles: [0,0,-90], isAdded: false),
//                          PathNode(position: SCNVector3(x: 1.8, y: -0.2, z: -0.3), rotationAngles: [-90,0,0], isAdded: false)]
    var nodePlacements: [PathNode] = []
    var currentNodeCount = 0
    var canAddNode = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        sceneView.delegate = self
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        scrollView.delegate = self
        loadMap()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView,
              let results = resultPath,
              results.count > 2 else { return }
        guard let currentFrame = sceneView.session.currentFrame else { return }
        if self.startingPosition != nil {
            self.startingPosition?.removeFromParentNode()
            self.startingPosition = nil
            return
        }
        let camera = currentFrame.camera
        let transform = camera.transform
        var translationMatrix = matrix_identity_float4x4
        // set the first node manually on tap gesture handle of scene view, further nodes are added in ViewController + Delegate 
        translationMatrix.columns.3.z = -((Float(results[1].y) - Float(results[0].y))/100)
        let modifiedMatrix = simd_mul(transform, translationMatrix)
        let scene = SCNScene(named: "Arrow.scn")
        let sphere = (scene?.rootNode.childNode(withName: "sphere", recursively: false))!
        sphere.simdTransform = modifiedMatrix
        sphere.eulerAngles = SCNVector3(0,0,-90.degreesToRadians)
        self.sceneView.scene.rootNode.addChildNode(sphere)
        self.startingPosition = sphere
        DispatchQueue.main.async {
            self.currentCameralabel.text = "Node placed at \(sphere.position)"
        }
    }
    @IBAction func btnTapped(_ sender: Any) {
        self.currentCameralabel.text = "\(self.sceneView.session.currentFrame?.camera.transform)"
    }
}


extension Int {
    var degreesToRadians: Double { return Double(self) * .pi/180 }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        mapView
    }
}



