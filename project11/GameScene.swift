//
//  GameScene.swift
//  project11
//
//  Created by Ярослав on 4/5/21.
//

import SpriteKit

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var scoreLable: SKLabelNode!
    var score = 0{
        didSet{
            scoreLable.text = "Score: \(score)"
        }
    }
    
    var editingLable: SKLabelNode!
    
    var editingMode = false{
        didSet{
            if editingMode{
                editingLable.text = "Done"
            }else{
                editingLable.text = "Edit"
            }
        }
    }
    
    var ballsLable: SKLabelNode!
    
    var ballsAmount = 5{
        didSet{
            ballsLable.text = "Balls: \(ballsAmount)"
        }
    }
    
    var isAllGood: Bool = true
    
    override func didMove(to view: SKView) {
       let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        addChild(background)
        background.blendMode = .replace
        background.zPosition =  -1
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        scoreLable = SKLabelNode(fontNamed: "Chalckduster")
        scoreLable.text = "Score: 0"
        scoreLable.horizontalAlignmentMode = .right
        scoreLable.position = CGPoint(x: 980, y: 700)
        addChild(scoreLable)
        
        editingLable = SKLabelNode(fontNamed: "Chalckduster")
        editingLable.text = "Edit"
        editingLable.horizontalAlignmentMode = .center
        editingLable.position = CGPoint(x: 80, y: 700 )
        addChild(editingLable)
        
        ballsLable = SKLabelNode(fontNamed: "Chalckduster")
        ballsLable.text = "Balls: 5"
        ballsLable.horizontalAlignmentMode = .center
        ballsLable.position = CGPoint(x: frame.midX, y: frame.maxY - 30)
        addChild(ballsLable)
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let touch = touches.first else { return}
        
        let location = touch.location(in: self)
    
        let objects = nodes(at: location)
        
        if objects.contains(editingLable){
            editingMode.toggle()
        }else{
            if editingMode{
                // do box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.name = "box"
                
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                addChild(box)
            }else{
                if ballsAmount > 0{
                    let coloredBalls = ["ballRed","ballBlue","ballCyan","ballGreen","ballGrey","ballPurple","ballYellow"]
                    let ball = SKSpriteNode(imageNamed: coloredBalls[Int.random(in: 0..<coloredBalls.count)])//"ballRed")
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
                    ball.physicsBody?.restitution = 0.4
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                    ball.position = CGPoint(x: location.x, y: frame.maxY)//location
                    ball.name = "ball"
                    addChild(ball)
                } else{
                    ballsLable.text = "Game Over"
                }
                
            }
            
        }
        
        
       
    }
    
    func makeBouncer(at position: CGPoint){
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width/2)
        bouncer.physicsBody?.isDynamic = false
        bouncer.name = "bouncer"
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool){
        var slotBase = SKSpriteNode()
        var slotGlow = SKSpriteNode()
        
        if isGood{
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        }else{
            
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode){
        
        if object.name == "good"{
            ballsAmount -= 1
            if ballsAmount == 0{
                if isAllGood{
                    ballsAmount += 1
                }
            }
            destroy(ball: ball)
            score += 1
        }else if object.name == "bad"{
            destroy(ball: ball)
            isAllGood = false
            ballsAmount -= 1
            score -= 1
        }else if object.name == "box"{
            destroyBox(box: object)
        }
    }
    func destroyBox(box: SKNode){
        
        if let myParticle = SKEmitterNode(fileNamed: "MyParticle"){
            myParticle.position = box.position
            addChild(myParticle)
        }
        box.removeFromParent()
    }
    
    func destroy(ball: SKNode){
        
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles"){
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball"{
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball"{
            collision(between: nodeB, object: nodeA)
        }
    }
}
