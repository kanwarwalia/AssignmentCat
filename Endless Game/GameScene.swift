//
//  GameScene.swift
//  Endless Game
//
//  Created by kanwar walia on 2019-03-04.
//  Copyright © 2019 kanwar walia. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    private var lastUpdateTime : TimeInterval = 0
    
    private var screenWidth : CGFloat = 0.0
    private var screenHeight : CGFloat = 0.0
    private let background1 = SKSpriteNode(imageNamed: "background")
    private let background2 = SKSpriteNode(imageNamed: "background")
    private let dinosaur = SKSpriteNode(imageNamed: "dinosaur")
    var label : SKLabelNode?
    var restart : SKSpriteNode?
    var restartLabel : SKLabelNode?
    var high_score : SKLabelNode?
    var high_score_display : SKLabelNode?
    var current_score : SKLabelNode?
    var gameOver: Bool = false
    var backgroundMusic: SKAudioNode!
    var calcusTimer: Timer?
    var c_score: Int = 0
    var h_score: Int?
    
    // For Collision
    let cactusCategory: UInt32 = 0x1 << 1
    let dinossaurCategory: UInt32 = 0x1 << 2
    
    override func didMove(to view: SKView) {
        if let musicURL = Bundle.main.url(forResource: "SpaceTrip", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            addChild(backgroundMusic)
        }
        // get screen size
        screenWidth = self.size.width
        screenHeight = self.size.height
        print("screen size : height : \(screenHeight) and width : \(screenWidth)")
        // set h_score
        h_score = game.highScore
        print("starting game: high score : \(h_score)")
        
        // set position of background
        background1.position = CGPoint(x: -screenHeight/2,y: -screenWidth/2)
        background1.anchorPoint = CGPoint(x: 0,y: 0)
        background1.size = self.frame.size
        background2.position = CGPoint(x: background1.position.x + background1.size.width,y: background1.position.y)
        background2.anchorPoint = CGPoint(x: 0,y: 0)
        background2.size = self.frame.size
        
        // set dinosaur
        dinosaur.position = CGPoint(x: -270, y: -100 )
        dinosaur.size = CGSize(width: 100, height: 100)
        dinosaur.zPosition = 2
        dinosaur.physicsBody?.isDynamic=false
        
        // add backgroung to screen
        addChild(background1)
        addChild(background2)
        
        print("background 1 width: \(background1.size.width) and heigh: \(background1.size.height)")
        
        addChild(dinosaur)
        
        calcusTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true, block: {(timer) in self.createCactus()})
        
        // add scores to screen
        high_score = SKLabelNode(text: "High Score")
        high_score?.position = CGPoint(x: screenWidth / 2 - 240,y: 170)
        high_score?.zPosition = 2
        high_score?.fontColor = UIColor.white
        addChild(high_score!)
        
        high_score_display = SKLabelNode(text: "\(h_score)")
        high_score_display?.position = CGPoint(x: screenWidth / 2 - 130,y: 170)
        high_score_display?.zPosition = 2
        high_score_display?.fontColor = UIColor.white
        addChild(high_score_display!)
        
        current_score = SKLabelNode(text: "\(c_score)")
        current_score?.position = CGPoint(x: screenWidth / 2 - 80,y: 170)
        current_score?.zPosition = 2
        current_score?.fontColor = UIColor.white
        addChild(current_score!)
        
        physicsWorld.contactDelegate = self
        dinosaur.physicsBody = SKPhysicsBody(rectangleOf:self.dinosaur.frame.size)
        dinosaur.physicsBody?.affectedByGravity = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        if (dt > 1) {
            self.lastUpdateTime = currentTime
            c_score = c_score + 1
        }
        if(!gameOver){
            // update position of background1 and background2
            background1.position = CGPoint(x: background1.position.x - 4,y: background1.position.y)
            background2.position = CGPoint(x: background2.position.x - 4,y: background2.position.y)
            
            if(background2.position.x < -screenHeight + 200){
                print("first loop")
                background2.position = CGPoint(x: background1.position.x + (background1.size.width), y: background2.position.y)
            }
            
            if(background1.position.x < -screenHeight + 200){
                print("second loop")
                background1.position = CGPoint(x: background2.position.x + (background2.size.width), y: background1.position.y)
            }
            
            // update current_score
            current_score?.text = "\(c_score)"
            // update high_score
            if c_score > (game.getHighScore()) {
                game.setHighScore(val: c_score)
            }
            high_score_display?.text = "\(game.getHighScore() ?? 0)"
            //high_score_display?.text = "\(String(describing: h_score))"
        }
        else{
            gameEnded()
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // make dinosaur jump
        
        if(!gameOver){
            let moveAction1 = SKAction.moveBy(x: 0, y: 220, duration: 0.65)
            let moveAction2 = SKAction.moveBy(x: 0, y: -220, duration: 0.65)
            
            let sequence:SKAction = SKAction.sequence([moveAction1,moveAction2])
            
            dinosaur.run(sequence)
        }
        else{
            for touch in touches{
                let location = touch.location(in: self)
                let node = atPoint(location)
                
                if(node == restart || node == restartLabel){
                    resetGame()
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        print("Contact!!!")
        gameEnded()
    }
    
    // function to create cactus on screen
    func createCactus(){
        if(!gameOver){
            let cactus = SKSpriteNode(imageNamed: "cactus")
            
            // 2. Give it position
            cactus.position = CGPoint(x:270,y: -80)
            cactus.size = CGSize(width: 70, height: 130)
            cactus.physicsBody = SKPhysicsBody(rectangleOf: cactus.size)
            cactus.physicsBody?.affectedByGravity = false
            
            //For collision
            cactus.physicsBody?.categoryBitMask = cactusCategory
            cactus.physicsBody?.contactTestBitMask = cactusCategory
            cactus.physicsBody?.collisionBitMask = 0
            
            // 3. Add square to the screen
            addChild(cactus)
            
            // add action to cactus
            let moveLeft = SKAction.moveBy(x: -size.width, y: 0, duration: 2)
            let sequence = SKAction.sequence([moveLeft, SKAction.removeFromParent()])
            cactus.run(sequence)
        }
    }
    
    // func to handle events once game is over
    func gameEnded(){
        // create label 'Game Over'
        label = SKLabelNode(text: "Game Over")
        label!.position = CGPoint(x: 0, y: 100)
        label!.fontSize = 45
        label!.fontColor = SKColor.yellow
        label!.fontName = "Avenir"
        addChild(label!)
        
        // set gameOver to true
        gameOver = true;
        
        // create restart button
        restart = SKSpriteNode(color: SKColor.brown,
                               size: CGSize(width: 135, height: 30))
        restart!.position = CGPoint(x:0,y:11)
        addChild(restart!)
        restartLabel = SKLabelNode(text: "Restart")
        restartLabel!.position = CGPoint(x: 0, y: 0)
        restartLabel!.fontSize = 35
        restartLabel!.fontColor = SKColor.yellow
        restartLabel!.fontName = "Avenir"
        addChild(restartLabel!)
    }
    
    func resetGame(){
        
        print("high score: \(game.getHighScore())")
        c_score = 0
        gameOver = false
        
        let gameSceneTemp = GameScene(fileNamed: "GameScene")
        gameSceneTemp?.scaleMode = self.scaleMode
        self.scene?.view?.presentScene(gameSceneTemp!, transition: SKTransition.doorsCloseHorizontal(withDuration: 0.0))
    }
}
