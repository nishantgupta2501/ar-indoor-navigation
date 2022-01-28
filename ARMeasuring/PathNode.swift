//
//  File.swift
//  ARMeasuring
//
//  Created by Nishant Gupta on 24/1/22.
//

import Foundation
import SceneKit


struct PathNode {
    let position: SCNVector3
    let rotationAngles: [Int]
    var isAdded:Bool
    var placedNode: SCNNode?
}
