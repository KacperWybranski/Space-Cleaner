//
//  SteeringNode.swift
//  flightSimulator
//
//  Created by Kacper on 20/08/2020.
//  Copyright © 2020 Kacper. All rights reserved.
//

import UIKit
import SpriteKit

class SteeringNode: SKShapeNode {
    var rectOfNode: CGRect!
    @objc dynamic var ball: SKShapeNode!
    @objc dynamic var ballBeingTouched: Bool = false
    
    init(rect: CGRect, cornerRadius: CGFloat) {
        super.init()
        
        rectOfNode = rect
        
        path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: .none)
        lineWidth = 1
        strokeColor = .white
        glowWidth = 1
        fillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        setupBall(radius: cornerRadius-10)
        addChild(ball)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBall(radius: CGFloat) {
        ball = SKShapeNode(circleOfRadius: radius)
        ball.position = CGPoint(x: 120, y: 70)
        ball.lineWidth = 1
        ball.fillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        ball.strokeColor = .white
        ball.glowWidth = 1
        ball.name = "ball"
        
        let ballHitbox = SKShapeNode(circleOfRadius: radius+30)
        ballHitbox.position = CGPoint(x: 0, y: 0)
        ballHitbox.name = "ballHitbox"
        ballHitbox.lineWidth = 0
        ball.addChild(ballHitbox)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let node = nodes(at: location).first {
            if node.name == "ballHitbox" {
                ballInteractedWith(.touchBegan, touch: nil)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let node = nodes(at: location).first {
            if node.name == "ballHitbox" {
                ballInteractedWith(.touchEnded, touch: nil)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let node = nodes(at: location).first {
            if node.name == "ballHitbox" {
                ballInteractedWith(.touchMoved, touch: touch)
                return
            }
        }
        ballInteractedWith(.touchEnded, touch: nil)
    }
    
    func ballInteractedWith(_ interaction: Interaction, touch: UITouch?) {
        switch interaction {
        case .touchEnded:
            ballBeingTouched = false
            let pulseUp = SKAction.scale(to: 1.0, duration: 0.1)
            let moveBack = SKAction.move(to: CGPoint(x: 120, y: 70), duration: 0.1)
            ball.run(SKAction.group([pulseUp,moveBack]))
            
        case .touchBegan:
            ballBeingTouched = true
            let pulseDown = SKAction.scale(to: 0.90, duration: 0.1)
            ball.run(pulseDown)
            fallthrough
            
        case .touchMoved:
            if let touchLocation = touch?.location(in: self) {
                switch touchLocation.x {
                case 0..<60:
                    ball.position.x = 60
                case 60...180:
                    ball.position.x = touchLocation.x
                default:
                    ball.position.x = 180
                }
            }
        }
    }
}

enum Interaction {
    case touchBegan
    case touchEnded
    case touchMoved
}
