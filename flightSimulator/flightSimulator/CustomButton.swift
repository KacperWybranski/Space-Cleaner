//
//  CustomButton.swift
//  flightSimulator
//
//  Created by Kacper on 28/08/2020.
//  Copyright © 2020 Kacper. All rights reserved.
//

import UIKit
import SpriteKit

class CustomButton: SKShapeNode {
    var rectOfNode: CGRect!
    @objc dynamic var beingTouched: Bool = false
    
    init(rect: CGRect, cornerRadius: CGFloat, text: String?) {
        super.init()
        
        rectOfNode = rect
        
        path = CGPath(roundedRect: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: .none)
        lineWidth = 1
        strokeColor = .white
        glowWidth = 1
        fillColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        
        isUserInteractionEnabled = true
        
        if let textToWrite = text {
            addTextOnTop(text: textToWrite)
        }
    }
    
    func addTextOnTop(text: String) {
        let textNode = SKLabelNode(text: text)
        textNode.fontColor = .white
        textNode.fontSize = 60
        textNode.position = CGPoint(x: rectOfNode.midX, y: rectOfNode.midY-rectOfNode.height/4)
        addChild(textNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beingTouched = true
        let pulseDown = SKAction.scale(to: 0.9, duration: 0.1)
        let movement = SKAction.move(to: CGPoint(x: rectOfNode.width/10.0, y: rectOfNode.height/3.0), duration: 0.1)
        self.run(SKAction.group([pulseDown,movement]))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        beingTouched = false
        let pulseUp = SKAction.scale(to: 1.0, duration: 0.1)
        let movement = SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0.1)
        self.run(SKAction.group([pulseUp, movement]))
    }
}
