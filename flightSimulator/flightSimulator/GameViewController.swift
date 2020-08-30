//
//  GameViewController.swift
//  flightSimulator
//
//  Created by Kacper on 17/08/2020.
//  Copyright © 2020 Kacper. All rights reserved.
//

import UIKit
import SceneKit
import SpriteKit

class GameViewController: UIViewController, SCNPhysicsContactDelegate, SCNSceneRendererDelegate {

    var sceneView: SCNView!
    var scene: SCNScene!
    
    var earthNode: SCNNode!
    var shipNode: SCNNode!
    var laserHelpNode: SCNNode!
    
    var overlay: OverlayScene!
    
    var targets = [SCNNode]()
    
    var gameTimer: Timer!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupNodes()
        setupOverlay()
        overlay.showStartMenu(withDuration: nil)
    }
    
    func setupScene() {
        sceneView = (self.view as! SCNView)
        sceneView.delegate = self
        
        scene = SCNScene(named: "art.scnassets/mainScene.scn")
        scene.physicsWorld.contactDelegate = self
        sceneView.scene = scene
    }
    
    func setupNodes() {
        earthNode = scene.rootNode.childNode(withName: "earth", recursively: true)!
        earthNode.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
        let action = SCNAction.rotate(by: -CGFloat.pi*2.0, around: SCNVector3(0,1,0), duration: 30)
        let repeatAction = SCNAction.repeatForever(action)
        earthNode.runAction(repeatAction)
        
        shipNode = scene.rootNode.childNode(withName: "ship", recursively: true)!
        shipNode.physicsBody!.physicsShape = SCNPhysicsShape(node: shipNode, options: nil)
        shipNode.physicsBody!.categoryBitMask = 4
        
        let clearingWallNode = scene.rootNode.childNode(withName: "clearingWall", recursively: true)!
        clearingWallNode.physicsBody!.categoryBitMask = 4
    }
    
    func setupOverlay() {
        overlay = OverlayScene(size: view.bounds.size)
        overlay.addObserver(self, forKeyPath: #keyPath(OverlayScene.steeringNode.ball.position), options: .new, context: nil)
        overlay.addObserver(self, forKeyPath: #keyPath(OverlayScene.steeringNode.ballBeingTouched), options: .new, context: nil)
        overlay.addObserver(self, forKeyPath: #keyPath(OverlayScene.shootingButton.buttonBeeingTouched), options: .new, context: nil)
        overlay.addObserver(self, forKeyPath: #keyPath(OverlayScene.startButton.beingTouched), options: .new, context: nil)
        sceneView.overlaySKScene = overlay
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(OverlayScene.steeringNode.ball.position) {
            if let scene = object as? OverlayScene {
                let x = (scene.steeringNode.ball.position.x - 120.0) / 60.0
                changePlanePosition(byX: x, slowly: false)
            }
        }
        
        if keyPath == #keyPath(OverlayScene.steeringNode.ballBeingTouched) {
            changePlanePosition(byX: 0.0, slowly: true)
        }
        
        if keyPath == #keyPath(OverlayScene.shootingButton.buttonBeeingTouched) {
            if let scene = object as? OverlayScene {
                if scene.shootingButton.buttonBeeingTouched == false {
                    fireLaser()
                }
            }
        }
        
        if keyPath == #keyPath(OverlayScene.startButton.beingTouched) {
            if let scene = object as? OverlayScene {
                if scene.startButton.beingTouched == false {
                    startGame()
                }
            }
        }
    }
    
    func changePlanePosition(byX x: CGFloat, slowly: Bool) {
        if slowly {
            let moveToCenter = SCNAction.move(to: SCNVector3(0, 0, 0), duration: 0.2)
            shipNode.runAction(moveToCenter)
        } else {
            shipNode.position.z = Float(x)
        }
    }
    
    func generateTarget(timeAfterFire i: Float) {
        let randomY = Float.random(in: -0.20...0.20)
        let colors: [UIColor] = [.red, .red, .red, .green]

        var newGeometry = SCNGeometry()
        newGeometry = SCNSphere(radius: 0.05)

        let randomColor = colors.randomElement()!

        let newMaterial = SCNMaterial()
        newMaterial.diffuse.contents = randomColor
        newGeometry.materials = [newMaterial]

        let newNode = SCNNode(geometry: newGeometry)
        newNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        newNode.physicsBody!.isAffectedByGravity = false
        newNode.physicsBody!.contactTestBitMask = shipNode.physicsBody!.categoryBitMask
        newNode.physicsBody!.categoryBitMask = 2

        if randomColor == UIColor.red {
            newNode.name = "badTarget"
        } else {
            newNode.name = "goodTarget"
        }
        
        let x = -5.28*sin(2*i*Float.pi)
        let z = -5.28*cos(2*i*Float.pi)
        
        newNode.position = SCNVector3(x, randomY, z)
        earthNode.addChildNode(newNode)
    }
    
    func fireLaser() {
        var laserHitboxGeometry = SCNGeometry()
        laserHitboxGeometry = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0.0)
        
        var laserTextureGeometry = SCNGeometry()
        laserTextureGeometry = SCNBox(width: 0.05, height: 0.05, length: 0.3, chamferRadius: 0.0)
        let laserTextureNode = SCNNode(geometry: laserTextureGeometry)
        
        let laserHitboxMaterial = SCNMaterial()
        laserHitboxMaterial.diffuse.contents = UIColor.clear
        laserHitboxMaterial.lightingModel = .constant
        laserHitboxGeometry.materials = [laserHitboxMaterial]
        
        let laserMaterial = SCNMaterial()
        laserMaterial.diffuse.contents = UIColor.cyan
        laserMaterial.lightingModel = .constant
        laserTextureGeometry.materials = [laserMaterial]
        
        let laserHitboxNode = SCNNode(geometry: laserHitboxGeometry)
        laserHitboxNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        laserHitboxNode.physicsBody!.isAffectedByGravity = true
        laserHitboxNode.physicsBody!.collisionBitMask = 0
        laserHitboxNode.physicsBody!.categoryBitMask = 0
        laserHitboxNode.physicsBody!.velocity = SCNVector3(0,0.5,-5)
        laserHitboxNode.physicsBody!.contactTestBitMask = 2
        
        laserHitboxNode.worldPosition = shipNode.worldPosition
        
        laserHitboxNode.name = "laser"
        laserHitboxNode.addChildNode(laserTextureNode)
        scene.rootNode.addChildNode(laserHitboxNode)
        
        let wait = SCNAction.wait(duration: 0.5)
        let remove = SCNAction.removeFromParentNode()
        let laserSequence = SCNAction.sequence([wait, remove])
        laserHitboxNode.runAction(laserSequence)
    }
    
    func startGame() {
        overlay.score = 0
        overlay.showGameSteering()
        
        earthNode.rotation = SCNVector4(0, 0, 0, 0)
        
        var i: Float = 0.0
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in

            if i < 30 {
                i += Float(timer.timeInterval/30.0)
            } else {
                i = 0.0
            }

            self?.generateTarget(timeAfterFire: i)
        }
    }
    
    func endGame() {
        gameTimer.invalidate()
        for node in earthNode.childNodes {
            if let name = node.name {
                if name.hasSuffix("Target") {
                    node.removeFromParentNode()
                }
            }
        }
        overlay.showEndScreen()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        var targetNode: SCNNode!
        var staticNode: SCNNode!
        
        if contact.nodeA.name!.hasSuffix("Target") {
            targetNode = contact.nodeA
            staticNode = contact.nodeB
        } else if contact.nodeB.name!.hasSuffix("Target") {
            targetNode = contact.nodeB
            staticNode = contact.nodeA
        }
        
        switch staticNode.name {
        case "ship":
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            endGame()
        case "clearingWall":
            if targetNode.name!.hasPrefix("bad") {
                targetNode.removeFromParentNode()
                endGame()
            } else {
                targetNode.removeFromParentNode()
                overlay.score += 1
            }
        case "laser":
            staticNode.removeFromParentNode()
            if targetNode.name!.hasPrefix("bad") {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                targetNode.removeFromParentNode()
                overlay.score += 1
            } else {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                targetNode.removeFromParentNode()
                endGame()
            }
        default:
            return
        }
    }
}
