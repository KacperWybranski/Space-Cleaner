//
//  ShootButton.swift
//  flightSimulator
//
//  Created by Kacper on 21/08/2020.
//  Copyright © 2020 Kacper. All rights reserved.
//

import UIKit
import SpriteKit

class ShootButton: SKShapeNode {
    var ball: SKShapeNode!
    var rectOfShootButton: CGRect!
    @objc dynamic var buttonBeeingTouched: Bool = false

    init(rect: CGRect) {
        super.init()

        rectOfShootButton = rect
        
        path = CGPath(roundedRect: rect, cornerWidth: rect.width/2.0, cornerHeight: rect.height/2.0, transform: .none)
        lineWidth = 1
        strokeColor = .white
        glowWidth = 1
        fillColor = UIColor(white: 1, alpha: 0.2)
        
        setupBall(radius: rect.width/2.0-10)
        addChild(ball)
        
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBall(radius: CGFloat) {
        ball = SKShapeNode(circleOfRadius: radius)
        ball.position = CGPoint(x: rectOfShootButton.midX, y: rectOfShootButton.midY)
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
                buttonBeeingTouched = true
                let pulseDown = SKAction.scale(to: 0.9, duration: 0.1)
                ball.run(pulseDown)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let node = nodes(at: location).first {
            if node.name == "ballHitbox" {
                buttonBeeingTouched = false
                let pulseUp = SKAction.scale(to: 1.0, duration: 0.1)
                ball.run(pulseUp)
            }
        }
    }
}
