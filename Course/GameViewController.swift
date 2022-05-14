//
//  GameViewController.swift
//  Course
//
//  Created by Дмитрий Цветков on 16.02.2022.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController, SCNSceneRendererDelegate {
    var scnView: SCNView! // Отображает содержимое сцены scnScene на экране
    var gameScene: Scene? // Сцена. Сюда добавляем компоненты (свет, камера, частицы)
    var menuScene: Menu?
    var cameraNode: SCNNode!
    var firstBox: SCNNode!
    var ball: SCNNode!
    var left = Bool()
    var tempBox: SCNNode!
    var firstBoxNumber = Int()
    var prevBoxNumber = Int()
    var floor: SCNNode!
    
    static var overlay: Overlay?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupScene()
    }

    override func viewDidAppear(_ animated: Bool) { // Вызывается после появления View на экране
        super.viewDidAppear(true)
        if let overlay = GameViewController.overlay{ // Если мы в оверлее
            overlay.silentScoreUpdate() // На экране появляется лейбл с числом очков
            overlay.silentScoreHeartUpdate() // На экране появляется лейбл с числом жизней
        }
    }
    

    

    func setupView(){
        scnView = self.view as! SCNView
    }
    func setupScene(){
        menuScene = Menu(create: true)
        GameViewController.overlay = Overlay(main: self, size: self.view.frame.size)
 
        if let scene = menuScene, let overlay = GameViewController.overlay{
            scnView.scene = scene
            scnView.isPlaying = true
            scnView.delegate = scene
            scnView.overlaySKScene = overlay
            scnView.backgroundColor = UIColor.blue
        }
        
        scnView.showsStatistics = true // Показывает статистику
    }

    func checkNodeAtPosition(_ touch:  UITouch) -> String? {
        if let Overley = GameViewController.overlay{
            let location = touch.location(in: scnView)
            let node = Overley.atPoint(CGPoint(x: location.x, y: self.scnView.frame.size.height - location.y))
            if let name = node.name{
                return name //Возращаем имя нода
            } else {
                return nil
            }
        }else{
            return nil
        }
    }
    
    func changeScene(_ setupScene: SCNScene?, setupDelegate: SCNSceneRendererDelegate?, completion: (()->Void)!){// Отвечает за смену сцены
        if let scene = setupScene, let overlay = GameViewController.overlay, let delegate = setupDelegate{
            overlay.removeAllChildren()
            scnView.scene = scene
            scnView.delegate = setupDelegate
            completion()
        }
    }
    
    func touch(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let scene = gameScene { // Если мы находимся на игровой сцене
            print(scene.ball.presentation.worldPosition.y)
            print(scene.epmtyCharacter.presentation.worldPosition.y)
            if (scene.epmtyCharacter.presentation.position.y <= -0.95) { // Если персонаж находится на земле
                if let overlay = GameViewController.overlay{
                    if overlay.scoreHeartNumber > 0{
                        scene.epmtyCharacter.physicsBody?.velocity = SCNVector3Make(0, 3, 0)// Направление скорости по y (вверх)
                    } else{
                        scene.epmtyCharacter.physicsBody?.velocity = SCNVector3Zero
                    }
                    
                }
                
            
           }
        }

        if let touch = touches.first{
            if let name = checkNodeAtPosition(touch){
                if name == "play"{
                    gameScene = Scene(create: true)
                    changeScene(gameScene, setupDelegate: gameScene) {
                        GameViewController.overlay!.addScoreLabel() // Добавляем в игровую сцену очки
                        GameViewController.overlay!.addScoreHeartLabel() // Добавляем в игровую сцену жизни
                        GameViewController.overlay!.addHeartPicture()
                        self.menuScene = nil //Убираем сцену-меню
                    }
                } else if name == "replay"{
                    menuScene = Menu(create: true)
                    changeScene(menuScene, setupDelegate: menuScene) {
                        GameViewController.overlay!.addMenuItems()
                        self.gameScene = nil
                    }
                }
            }
        }
    }
}
