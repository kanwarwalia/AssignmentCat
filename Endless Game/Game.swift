//
//  Game.swift
//  Endless Game
//
//  Created by kanwar walia on 2019-03-04.
//  Copyright © 2019 kanwar walia. All rights reserved.
//

import Foundation

class Game {
    
    public var highScore: Int = 0
    public var gameOver: Bool = false
    
    func setGameOverValue(val: Bool){
        self.gameOver = val
    }
    
    func getGameOverValue() -> Bool {
        return self.gameOver
    }
    func setHighScore(val: Int){
        self.highScore = val
    }
    
    func getHighScore()->Int{
        return self.highScore
    }
    
}

var game:Game = Game()
