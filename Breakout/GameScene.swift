//
//  GameScene.swift
//  Breakout
//
//  Created by Alvin Tuo on 7/10/19.
//  Copyright © 2019 Swift. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var ball = SKShapeNode()
    var paddle = SKSpriteNode()
    var bricks = [SKSpriteNode]()
    var loseZone = SKSpriteNode()
    var livesCounter = SKLabelNode()
    var scoreCounter = SKLabelNode()
    var startScreen = SKLabelNode()
    var endScreen = SKLabelNode()
    var index = 0
    var score = 0
    var count = 0
    var lives = 3
    var isStarted = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        createBackground()
        startGame()
        makeBall()
        makePaddle()
        brickCreator()
        makeLoseZone()
        showLives(lives: lives)
    }
    
    func makeBall() {
        ball = SKShapeNode(circleOfRadius: 10)
        ball.position = CGPoint(x: frame.midX, y: frame.midY + 10)
        ball.strokeColor = UIColor.black
        ball.fillColor = UIColor.yellow
        ball.name = "ball"
        
        // physics shape matches ball image
        ball.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        // ignores all forces and impulses
        ball.physicsBody?.isDynamic = false
        // use precise collision detection
        ball.physicsBody?.usesPreciseCollisionDetection = true
        // no loss of energy from friction
        ball.physicsBody?.friction = 0
        // gravity is not a factor
        ball.physicsBody?.affectedByGravity = false
        // bounces fully off of other objects
        ball.physicsBody?.restitution = 1
        // does not slow down over time
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.contactTestBitMask = (ball.physicsBody?.collisionBitMask)!
        
        addChild(ball) // add ball object to the view
        
    }
    
    func createBackground() {
        let stars = SKTexture(imageNamed: "stars")
        for i in 0...1 {
            let starsBackground = SKSpriteNode(texture: stars)
            starsBackground.zPosition = -1
            starsBackground.position = CGPoint(x: 0, y: starsBackground.size.height * CGFloat(i))
            addChild(starsBackground)
            let moveDown = SKAction.moveBy(x: 0, y: -starsBackground.size.height, duration: 20)
            let moveReset = SKAction.moveBy(x: 0, y: starsBackground.size.height, duration: 0)
            let moveLoop = SKAction.sequence([moveDown, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            starsBackground.run(moveForever)
        }
    }
    
    func makePaddle() {
        paddle = SKSpriteNode(color: UIColor.white, size: CGSize(width: frame.width/4, height: 20))
        paddle.position = CGPoint(x: frame.midX, y: frame.minY + 125)
        paddle.name = "paddle"
        paddle.physicsBody = SKPhysicsBody(rectangleOf: paddle.size)
        paddle.physicsBody?.isDynamic = false
        addChild(paddle)
    }
    
    func makeBrick(color: String, x: CGFloat, y: CGFloat) {
        let brick = SKSpriteNode(color: UIColor.blue, size: CGSize(width: 50, height: 20))
        brick.position = CGPoint(x: x, y: y)
            if color == "green" {
                brick.color = .green
            }
            if color == "yellow" {
                brick.color = .yellow
            }
            if color == "red" {
                brick.color = .red
            }

        brick.name = "brick\(index)"
        index += 1
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size)
        brick.physicsBody?.isDynamic = false
        bricks.append(brick)
        addChild(brick)
    }
    
    func makeLoseZone() {
        loseZone = SKSpriteNode(color: UIColor.red, size: CGSize(width: frame.width, height: 50))
        loseZone.position = CGPoint(x: frame.midX, y: frame.minY + 25)
        loseZone.name = "loseZone"
        loseZone.physicsBody = SKPhysicsBody(rectangleOf: loseZone.size)
        loseZone.physicsBody?.isDynamic = false
        addChild(loseZone)
    }
    
    override func update(_ currentTime: TimeInterval) {
        var xSpeed = ball.physicsBody!.velocity.dx
        xSpeed = sqrt(xSpeed * xSpeed)
        if xSpeed < 10 {
            ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 0))
        }
        var ySpeed = ball.physicsBody!.velocity.dy
        ySpeed = sqrt(ySpeed * ySpeed)
        if ySpeed < 10 {
            ball.physicsBody?.applyImpulse(CGVector(dx: 0, dy: Int.random(in: -3...3)))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endScreen.alpha = 0
        startScreen.alpha = 0
        if !isStarted {
            ball.physicsBody?.isDynamic = true
            ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 5))
            isStarted = true
        }
        for touch in touches {
            let location = touch.location(in: self)
            paddle.position.x = location.x
//            paddle.position.y = location.y
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.position.x = location.x
//            paddle.position.y = location.y
        }
    }
    
    func showLives (lives: Int) {
        livesCounter = SKLabelNode(fontNamed: "Futura")
        livesCounter.text = "Lives Left: \(lives)"
        livesCounter.fontSize = 24
        livesCounter.fontColor = SKColor.white
        livesCounter.position = CGPoint(x: frame.midX, y: frame.midY - 88)
        addChild(livesCounter)
    }
    
    func showScore (score: Int) {
        scoreCounter = SKLabelNode(fontNamed: "Futura")
        scoreCounter.text = "Score: \(score)"
        scoreCounter.fontSize = 24
        scoreCounter.fontColor = SKColor.white
        scoreCounter.position = CGPoint(x: frame.midX, y: frame.minY + 18)
        addChild(scoreCounter)
    }
    
    func startGame () {
        startScreen = SKLabelNode(fontNamed: "Futura")
        startScreen.text = "Tap Anywhere to Start"
        startScreen.fontSize = 28
        startScreen.fontColor = SKColor.white
        startScreen.position = CGPoint(x: frame.midX, y: frame.midY)
        startScreen.alpha = 1
        addChild(startScreen)
    }
    
    func endGame () {
        endScreen = SKLabelNode(fontNamed: "Futura")
        endScreen.text = ""
        endScreen.fontSize = 28
        endScreen.fontColor = SKColor.white
        endScreen.position = CGPoint(x: frame.midX, y: frame.midY)
        endScreen.alpha = 0
        addChild(endScreen)
    }
    
    func resetGame () {
        paddle.removeFromParent()
        index = 0
        score = 0
        count = 0
        lives = 3
        ball.removeFromParent()
        for brick in bricks {
            brick.removeFromParent()
            bricks.remove(at: bricks.firstIndex(of: brick)!)
        }
        livesCounter.text = "Lives Left: 3"
        scoreCounter.text = "Score: 0"
        isStarted = false
        makeBall()
        makePaddle()
        brickCreator()
        endGame()
        endScreen.alpha = 1
    }
    
    func brickCreator () {
        var xcount = 30
        while(xcount < Int(frame.maxX - 30)) {
            makeBrick(color: "red", x: CGFloat(xcount), y: CGFloat(frame.maxY - 50))
            xcount += 60
        }
        var xcount2 = 30
        while(xcount2 < Int(frame.maxX - 30)) {
            makeBrick(color: "yellow", x: CGFloat(xcount2), y: CGFloat(frame.maxY - 80))
            xcount2 += 60
        }
        var xcount3 = 30
        while(xcount3 < Int(frame.maxX - 30)) {
            makeBrick(color: "green", x: CGFloat(xcount3), y: CGFloat(frame.maxY - 110))
            xcount3 += 60
        }
        var xcount4 = -30
        while(xcount4 > Int(frame.minX + 30)) {
            makeBrick(color: "red", x: CGFloat(xcount4), y: CGFloat(frame.maxY - 50))
            xcount4 -= 60
        }
        var xcount5 = -30
        while(xcount5 > Int(frame.minX + 30)) {
            makeBrick(color: "yellow", x: CGFloat(xcount5), y: CGFloat(frame.maxY - 80))
            xcount5 -= 60
        }
        var xcount6 = -30
        while(xcount6 > Int(frame.minX + 30)) {
            makeBrick(color: "green", x: CGFloat(xcount6), y: CGFloat(frame.maxY - 110))
            xcount6 -= 60
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        for brick in bricks {
            if contact.bodyA.node?.name == brick.name || contact.bodyB.node?.name == brick.name {
                scoreCounter.text = ""
                score += 1
                showScore(score: score)
                
                if brick.color == .red {
                    brick.color = .yellow
                }
                else if brick.color == .yellow {
                    brick.color = .green
                }
                else if brick.color == .green {
                    brick.removeFromParent()
                    bricks.remove(at: bricks.firstIndex(of: brick)!)
                    count += 1
                }
            }
            if count == index {
                endGame()
                resetGame()
                endScreen.text = "WIN; Tap to reset."
            }
        }
        if contact.bodyA.node?.name == "loseZone" ||
            contact.bodyB.node?.name == "loseZone" {
            if lives == 3 {
                lives -= 1
                ball.removeFromParent()
                 makeBall()
                ball.physicsBody?.isDynamic = true
                ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 5))
                livesCounter.text = ""
                showLives(lives: lives)
            }
            else if lives == 2 {
                lives -= 1
                ball.removeFromParent()
                makeBall()
                ball.physicsBody?.isDynamic = true
                ball.physicsBody?.applyImpulse(CGVector(dx: Int.random(in: -3...3), dy: 5))
                livesCounter.text = ""
                showLives(lives: lives)
            }
            else if lives == 1 {
                endGame()
                resetGame()
                endScreen.text = "LOSE; Tap to reset."
                
            }
        }
    }
}
