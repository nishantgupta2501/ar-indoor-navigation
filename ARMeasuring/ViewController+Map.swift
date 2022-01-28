//
//  ViewController+Map.swift
//  ARMeasuring
//
//  Created by Nishant Gupta on 28/1/22.
//

import UIKit
import GameplayKit

extension ViewController {
    func loadMap() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let roomLayer = CATextLayer()
        roomLayer.frame =  FixtureConstants.apartmentFixture
        roomLayer.backgroundColor = UIColor.white.cgColor
        mapView.layer.addSublayer(roomLayer)
        
        // add block
        let blockLayer = CALayer()
        blockLayer.frame = FixtureConstants.balconyFixture
        blockLayer.backgroundColor = UIColor.gray.cgColor
        mapView.layer.addSublayer(blockLayer)
        addObstacle(fixture: FixtureConstants.balconyFixture)
        
        // add room1
        let room1Layer = CALayer()
        room1Layer.frame = FixtureConstants.room1Fixture
        room1Layer.backgroundColor = UIColor.gray.cgColor
        mapView.layer.addSublayer(room1Layer)
        addObstacle(fixture: FixtureConstants.room1Fixture)
        
        // add block
        let outsideCupboardLayer = CALayer()
        outsideCupboardLayer.frame = FixtureConstants.outsideCoupboardFixture
        outsideCupboardLayer.backgroundColor = UIColor.gray.cgColor
        mapView.layer.addSublayer(outsideCupboardLayer)
        addObstacle(fixture: FixtureConstants.outsideCoupboardFixture)
        
        // room 2 wall
        let room2WallLayer = CALayer()
        room2WallLayer.frame = FixtureConstants.room2WallFixture
        room2WallLayer.backgroundColor = UIColor.gray.cgColor
        mapView.layer.addSublayer(room2WallLayer)
        addObstacle(fixture: FixtureConstants.room2WallFixture)
        
        
        //add sofa
        let sofaLayer = CALayer()
        sofaLayer.frame = FixtureConstants.sofaFixture
        sofaLayer.backgroundColor = UIColor.gray.cgColor
        mapView.layer.addSublayer(sofaLayer)
        addObstacle(fixture: FixtureConstants.sofaFixture)
        
        //add kitchen
        let kitchenLayer = CALayer()
        kitchenLayer.frame = FixtureConstants.kitchenFixture
        kitchenLayer.backgroundColor = UIColor.gray.cgColor
        mapView.layer.addSublayer(kitchenLayer)
        addObstacle(fixture: FixtureConstants.kitchenFixture)
        
        //add kitchen slab
        let kitchenSlabLayer = CALayer()
        kitchenSlabLayer.frame = FixtureConstants.kitchenSlabFixture
        kitchenSlabLayer.backgroundColor = UIColor.gray.cgColor
        mapView.layer.addSublayer(kitchenSlabLayer)
        addObstacle(fixture: FixtureConstants.kitchenSlabFixture)
        
        //add bathrooms
        let bathroomsLayer = CALayer()
        bathroomsLayer.frame = FixtureConstants.bathroomsFixture
        bathroomsLayer.backgroundColor = UIColor.gray.cgColor
        mapView.layer.addSublayer(bathroomsLayer)
        addObstacle(fixture: FixtureConstants.bathroomsFixture)
        
        // add table
        let tableLayer = CALayer()
        tableLayer.frame = FixtureConstants.tableFixture
        tableLayer.backgroundColor = UIColor.brown.cgColor
        mapView.layer.addSublayer(tableLayer)
        addObstacle(fixture: FixtureConstants.tableFixture)
        
        // add tall boy
        let tallBoyLayer = CALayer()
        tallBoyLayer.frame = FixtureConstants.tallBoyFixture
        tallBoyLayer.backgroundColor = UIColor.yellow.cgColor
        mapView.layer.addSublayer(tallBoyLayer)
        addObstacle(fixture: FixtureConstants.tallBoyFixture)
        
        // add side table
        let sideTableLayer = CALayer()
        sideTableLayer.frame = FixtureConstants.sideTableFixture
        sideTableLayer.backgroundColor = UIColor.green.cgColor
        mapView.layer.addSublayer(sideTableLayer)
        addObstacle(fixture: FixtureConstants.sideTableFixture)
        
        
        // add bed
        let bedLayer = CALayer()
        bedLayer.frame = FixtureConstants.bedFixture
        bedLayer.backgroundColor = UIColor.red.cgColor
        mapView.layer.addSublayer(bedLayer)
        addObstacle(fixture: FixtureConstants.bedFixture)
        
        // add cupboard
        let coupboardLayer = CATextLayer()
        coupboardLayer.frame = FixtureConstants.cupboardFixture
        coupboardLayer.backgroundColor = UIColor.systemPink.cgColor
        mapView.layer.addSublayer(coupboardLayer)
        addObstacle(fixture: FixtureConstants.cupboardFixture)
        
        // add side table2
        let sideTable2Layer = CALayer()
        sideTable2Layer.frame = FixtureConstants.sideTable2Fixture
        sideTable2Layer.backgroundColor = UIColor.green.cgColor
        mapView.layer.addSublayer(sideTable2Layer)
        addObstacle(fixture: FixtureConstants.sideTable2Fixture)
        
        // create obstaclegrapgh
        self.obstacleGraph = GKObstacleGraph(obstacles: [], bufferRadius: 9)
        obstacleGraph!.addObstacles(obstacles)
        resultPath = pathFind(to: FixtureConstants.tableFixture, from: FixtureConstants.sideTable2Fixture)
        drawPath(pointResults: resultPath)
        populatePathNodes()
        let mapRect = CGRect(x: 0, y: 0, width: CGFloat(864), height: CGFloat(1074))
        scrollView.zoom(to: mapRect.insetBy(dx: 864/20, dy: 1074/20), animated: true)
    }
    
    func pathFind(to fixture: CGRect, from origin: CGRect) -> [CGPoint]? {
        let startNode = GKGraphNode2D(point: vector_float2(Float(startingPoint.x), Float(startingPoint.y)))
        
        let xPos: CGFloat = destination.x
        let yPos: CGFloat = destination.y
        //            let pathAdjustmentPadding: CGFloat = 44
        //            if fixture.face == .left {  //currently only works with LHS/RHS of aisles
        //                xPos -= pathAdjustmentPadding
        //            } else if fixture.face == .right {
        //                xPos += fixture.depth +  pathAdjustmentPadding
        //            } else { return nil }
        let endNode = GKGraphNode2D(point: vector_float2(Float(xPos), Float(yPos)))
        obstacleGraph?.connectUsingObstacles(node: startNode)
        obstacleGraph?.connectUsingObstacles(node: endNode)
        let results = obstacleGraph?.findPath(from: startNode, to: endNode)
        var pointResults: [CGPoint] = []
        results?.forEach { (result) in
            if let node = result as? GKGraphNode2D {
                pointResults.append(CGPoint(x: Int(node.position.x), y: Int(node.position.y)))
            }
        }
        return pointResults
    }
    
    private func drawPath(pointResults: [CGPoint]?) {
        guard let pointResults = pointResults, pointResults.count > 2 else {
            return
        }
        
        let path = UIBezierPath()
        path.move(to: pointResults[0])
        for count in 1...pointResults.count - 1 {
            path.addLine(to: CGPoint(x: pointResults[count].x, y: pointResults[count].y))
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.lineWidth = 2
        shapeLayer.fillColor = nil
        shapeLayer.strokeColor = UIColor.black.cgColor
        mapView.layer.addSublayer(shapeLayer)
    }
    
    private func addObstacle(fixture: CGRect) {
        let topLeft = SIMD2(x: Float(fixture.minX), y: Float(fixture.minY))
        let topRight = SIMD2(x: Float(fixture.maxX), y: Float(fixture.minY))
        let bottomRight = SIMD2(x: Float(fixture.maxX), y: Float(fixture.maxY))
        let bottomLeft = SIMD2(x: Float(fixture.minX), y: Float(fixture.maxY))
        let vertices = [topLeft, topRight, bottomRight, bottomLeft]
        let obstacle = GKPolygonObstacle(points: vertices)
        obstacles.append(obstacle)
    }
    
    private func populatePathNodes() {
        guard let results = resultPath, results.count > 2  else { return }
        for count in 2...results.count - 1 {
            let xDifference = Float(results[count].x) - Float(results[count - 1].x)
            let yDifference = Float(results[count].y) - Float(results[count - 1].y)
            // Divide by 100 to convert to meters
            nodePlacements.append(PathNode(position: SCNVector3(x: -xDifference/100, y: 0, z: -yDifference/100),
                                           rotationAngles: calculateAngles(currentIndex: count),
                                           isAdded: false,
                                           placedNode: nil))
        }
    }
    
    private func calculateAngles(currentIndex: Int) -> [Int] {
        var angles = [-90,0,0]
        guard let result = resultPath,
              result.count > currentIndex + 2 else { return angles}
        let xDifference = Float(result[currentIndex + 1].x) - Float(result[currentIndex].x)
        let yDifference = Float(result[currentIndex + 1].y) - Float(result[currentIndex].y)
        if xDifference < 0, yDifference >= 0 {
            if abs(yDifference) < abs(xDifference) {
                angles = [0,0,-90]
            } else {
                angles = [-90,0,0]
            }
        } else {
            if abs(yDifference) < abs(xDifference) {
                angles = [0,0,90]
            } else {
                angles = [90,0,0]
            }
        }
        return angles
    }
}
