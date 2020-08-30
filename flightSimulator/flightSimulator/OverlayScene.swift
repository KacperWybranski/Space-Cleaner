//
//  OverlayScene.swift
//  flightSimulator
//
//  Created by Kacper on 19/08/2020.
//  Copyright © 2020 Kacper. All rights reserved.
//

import UIKit
import SpriteKit

class OverlayScene: SKScene {
    
    var scoreNode: SKLabelNode!
    var bestNode: SKLabelNode!
    var mainLabelNode: SKLabelNode!
    @objc dynamic var steeringNode: SteeringNode!
    @objc dynamic var shootingButton: ShootButton!
    @objc dynamic var startButton: CustomButton!
    
    var score: Int = 0 {
        didSet {
            scoreNode.text = "Score: \(score)"
        }
    }
    
    override init(size: CGSize) {
        super.init(size: size)
        
        self.backgroundColor = .clear
        
        scoreNode = SKLabelNode(text: "Score: 0")
        scoreNode.fontColor = .white
        scoreNode.fontSize = 40
        scoreNode.position = CGPoint(x: size.width/2, y: size.height * 0.875)
        
        bestNode = SKLabelNode(text: "Best: \(bestScore())")
        bestNode.fontColor = .white
        bestNode.fontSize = 40
        bestNode.position = CGPoint(x: size.width/2, y: size.height * 0.63)
        
        steeringNode = SteeringNode(rect: CGRect(x: 10, y: 20, width: 220, height: 100), cornerRadius: 50)
        shootingButton = ShootButton(rect: CGRect(x: frame.width-110, y: 20, width: 100, height: 100))
        
        startButton = CustomButton(rect: CGRect(x: frame.width/2-110, y: frame.height/2-50, width: 220, height: 100), cornerRadius: 50, text: "PLAY")
        
        mainLabelNode = SKLabelNode(fontNamed: "Palatino-Italic")
        mainLabelNode.fontColor = .white
        mainLabelNode.fontSize = 30
        mainLabelNode.position = CGPoint(x: frame.midX, y: frame.maxY*0.8)
        mainLabelNode.text = "space cleaner beta"
        
        addChild(scoreNode)
        addChild(steeringNode)
        addChild(shootingButton)
        addChild(startButton)
        addChild(mainLabelNode)
        addChild(bestNode)
        scoreNode.alpha = 0.0
        steeringNode.alpha = 0.0
        shootingButton.alpha = 0.0
        startButton.alpha = 0.0
        mainLabelNode.alpha = 0.0
        bestNode.alpha = 0.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showGameSteering() {
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        startButton.run(fadeOut)
        mainLabelNode.run(fadeOut)
        bestNode.run(fadeOut)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        scoreNode.run(fadeIn)
        steeringNode.run(fadeIn)
        shootingButton.run(fadeIn)
        
        let moveUp = SKAction.moveTo(y: frame.height * 0.875, duration: 0.5)
        scoreNode.run(moveUp)
    }
    
    func showStartMenu(withDuration x: TimeInterval?) {
        let fadeIn = SKAction.fadeIn(withDuration: x ?? 0.5)
        startButton.run(fadeIn)
        mainLabelNode.run(fadeIn)
        bestNode.run(fadeIn)
    }
    
    func showEndScreen() {
        performSelector(inBackground: #selector(saveBestScore), with: nil)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        steeringNode.run(fadeOut)
        shootingButton.run(fadeOut)
        
        let moveDown = SKAction.moveTo(y: frame.height * 0.7, duration: 0.5)
        scoreNode.run(moveDown)
        
        let wait = SKAction.wait(forDuration: 0.5)
        let showStuff = SKAction.run {
            self.showStartMenu(withDuration: 0.5)
        }
        run(SKAction.sequence([wait,showStuff]))
    }
    
    @objc func saveBestScore() {
        let newScore = score
        let defaults = UserDefaults.standard
        
        if let best = defaults.object(forKey: "pb") as? Int {
            if newScore < best {
                return
            }
        }
        defaults.set(newScore, forKey: "pb")
        bestNode.text = "Best: \(newScore)"
    }
    
    func bestScore() -> Int {
        let defaults = UserDefaults.standard
        
        if let best = defaults.object(forKey: "pb") as? Int {
            return best
        }
        return 0
    }
}
