//
//  Overlay.swift
//  Course
//
//  Created by Дмитрий Цветков on 13.03.2022.
//
//
import UIKit
import SpriteKit
import SceneKit
class Overlay: SKScene{
    weak var mainView: GameViewController?
    var playButton = SKSpriteNode()
    var replayButton = SKSpriteNode()
    var picture = SKSpriteNode()
    var scoreLabel = SKLabelNode(fontNamed: "Arial")
    var bestScoreLabel = SKLabelNode(fontNamed: "Arial")
    var scoreNumber = 0
    var scoreHeartLabel = SKLabelNode(fontNamed: "Arial")
    var scoreHeartNumber = 1
    var pictureHeart = SKSpriteNode()
    var recordLabel = SKLabelNode(fontNamed: "Arial")
    
    convenience init(main: GameViewController, size: CGSize) {
        self.init(sceneSize: size)
        mainView = main
    }
    
    
    convenience init(sceneSize: CGSize) {
        self.init(size: sceneSize)
        
        let playTexture = SKTexture(image: UIImage(named: "play")!)
        playButton = SKSpriteNode(texture: playTexture)
        playButton.size = CGSize(width: 100, height: 100)
        playButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        playButton.position = CGPoint(x: self.size.width / 2, y: (self.size.height/2) - 200)
        playButton.name = "play"
        self.addChild(playButton)
        
        let replayTexture = SKTexture(image: UIImage(named: "replay")!)
        replayButton = SKSpriteNode(texture: replayTexture)
        replayButton.size = CGSize(width: 100, height: 100)
        replayButton.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        replayButton.position = CGPoint(x: self.size.width / 2, y: (self.size.height/2) - 200)
        replayButton.name = "replay"
        //self.addChild(replayButton)
        
        let pictureTexture = SKTexture(image: UIImage(named: "picture")!)
        picture = SKSpriteNode(texture: pictureTexture)
        picture.size = CGSize(width: 200, height: 200)
        picture.position = CGPoint(x: self.size.width / 2, y: (self.size.height/2) + 180)
        self.addChild(picture)
        
        
        
        let pictureHeartTexture = SKTexture(image: UIImage(named: "heart")!)
        pictureHeart = SKSpriteNode(texture: pictureHeartTexture)
        pictureHeart.size = CGSize(width: 80, height: 60)
        pictureHeart.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pictureHeart.position = CGPoint(x: self.size.width / 2 + 100, y: (self.size.height)-56)
        //self.addChild(pictureHeart)
        
        bestScoreLabel.text = String(UserDefaults.standard.integer(forKey: "score"))
        bestScoreLabel.fontColor = .yellow // Цвет текста
        bestScoreLabel.fontSize = 36 // Размер текста
        bestScoreLabel.position = CGPoint(x: self.size.width-20, y: (self.size.height/2)) // Позиция для очков
        self.addChild(bestScoreLabel)
        
        recordLabel.text = "Your best record:"
        recordLabel.fontColor = .yellow // Цвет текста
        recordLabel.fontSize = 36 // Размер текста
        recordLabel.position = CGPoint(x: self.size.width/2 - 15, y: (self.size.height/2)) // Позиция для текста
        self.addChild(recordLabel)
        
        scoreLabel.text = "0"
        scoreLabel.fontColor = .yellow // Цвет текста
        scoreLabel.fontSize = 64 // Размер текста
        scoreLabel.position = CGPoint(x: self.size.width/2, y: (self.size.height)-72) // Позиция для очков
        
        
        scoreHeartLabel.text = "1"
        scoreHeartLabel.fontColor = .red // Цвет текста
        scoreHeartLabel.fontSize = 64 // Размер текста
        scoreHeartLabel.position = CGPoint(x: self.size.width-20, y: (self.size.height)-72) // Позиция для очков
        
    }
    
    func addHeartPicture(){
        self.addChild(pictureHeart)
    }
    
    func addRecordText(){
        self.addChild(recordLabel)
    }
    
    func addScoreLabel(){
        replayButton.alpha = 0
        scoreNumber = 0
        scoreLabel.text = String(scoreNumber)
        self.addChild(scoreLabel)
    }
    
    func upcdateScoreLabel(){
        scoreNumber += 1 // Увеличиваем счетчик очков, когда собираем звезду
        scoreLabel.text = String(scoreNumber) // Передаем число очков, которое будет отображаться
    }
    func silentScoreUpdate(){ 
        self.addChild(scoreLabel) // Помещаем на сцену надпись с очками
        scoreLabel.text = " " // Убираем текст
    }
    
    func addScoreHeartLabel(){
        scoreHeartNumber = 1
        scoreHeartLabel.text = String(scoreHeartNumber)
        self.addChild(scoreHeartLabel)
    }
    func upcdateScoreHeartLabel(){
        scoreHeartNumber += 1 // Увеличиваем счетчик очков, когда собираем жизнь
        scoreHeartLabel.text = String(scoreHeartNumber) // Передаем число очков, которое будет отображаться
    }
    func reduceScoreHeartLabel(){
        if(scoreHeartNumber > 0){
            scoreHeartNumber -= 1
            scoreHeartLabel.text = String(scoreHeartNumber)
        }
    }
    func silentScoreHeartUpdate(){
        self.addChild(scoreHeartLabel) // Помещаем на сцену надпись с очками
        scoreHeartLabel.text = " " // Убираем текст
    }
    
    func addReplayButton(){ // Добавляет кнопку replay
        let opacityButton = SKAction.fadeAlpha(to: 1, duration: 0.5) // Действие - будет медленно проявляться кнопка в течении 0.5 сек
        self.addChild(replayButton)
        replayButton.run(opacityButton)
    }
    func addMenuItems(){
        self.addChild(picture)
        self.addChild(playButton)
        self.addChild(bestScoreLabel)
        self.addChild(recordLabel)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let main = mainView {
            main.touch(touches, with: event)
        }
    }
}
