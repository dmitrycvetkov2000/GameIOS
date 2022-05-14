//
//  Scene.swift
//  Course
//
//  Created by Дмитрий Цветков on 22.02.2022.
//
//Здесь настраиваем камеру, источники света, декорации
import UIKit
import SceneKit
class Scene: SCNScene, SCNSceneRendererDelegate, SCNPhysicsContactDelegate {
    var animations = [String: CAAnimation]()
    
    
    
    let emptyFloorAnimation1 = SCNNode() // Пустой нод, куда будем добавлять основные ноды
    let emptyFloorAnimation2 = SCNNode() // Пустой нод, куда будем добавлять основные ноды
    
    let epmtyCharacter = SCNNode()
    var ball = SCNNode()
    var anim = SCNNode()

    let emptyShuriken = SCNNode()
    var shuriken = SCNNode()
    
    let emptyStar = SCNNode()
    var star = SCNNode()
    
    let emptyHeart = SCNNode()
    var heart = SCNNode()
    
    var timeLast: Double?
    var speedFloor = -0.7 // Скорость (- с права налево)
    
    var runOfFloor = true
    
    var triggered = false
    
    var ballScene = SCNScene()
    
    enum ColliderCategory: Int{ // Чтобы определять столкновения тел
        case Ball = 1
        case Shuriken
        case Floor
        case Star
        case Heart
    }
    
    convenience init(create: Bool) { //Вспомогательный инициализатор
        self.init()
        setupCameraAndLight()
        setupFloor()

        physicsWorld.gravity = SCNVector3(0, -5.0, 0) // Применим мировую гравитацию ко всей сцене
        physicsWorld.contactDelegate = self // Говорим игре, что слушателем является текущий класс
        
        let sceneOne = SCNScene(named: "art.scnassets/SceneOne.scn")! // Объявляем сцену
        
        emptyFloorAnimation1.scale = SCNVector3(allScale: 0.09) // Уменьшаем размер нода, используя расширение
        emptyFloorAnimation1.position = SCNVector3(0, -1.2, 0) // Устанавливаем позицию нода(Накладываем поверх неподвижного пола)

        emptyFloorAnimation2.scale = SCNVector3(allScale: 0.09) // Уменьшаем размер нода, используя расширение
        emptyFloorAnimation2.position = SCNVector3(5.5, -1.2, 0) // Устанавливаем позицию второго нода(Накладываем поверх неподвижного пола)
        
        let floorAnimation1 = sceneOne.rootNode.childNode(withName: "FloorAnimation", recursively: true)! // Записываем пол в эту переменную из сцены
        floorAnimation1.position = SCNVector3(0, 0, 0)
        
        let floorAnimation2 = floorAnimation1.clone() // Записываем пол в эту перменную из сцены
        floorAnimation2.position = SCNVector3(0, 0, 0)
        
        emptyFloorAnimation1.addChildNode(floorAnimation1) // Добавляем в пустой нод нод пола
        emptyFloorAnimation2.addChildNode(floorAnimation2) // Добавляем в пустой нод нод пола
        rootNode.addChildNode(emptyFloorAnimation1) //Добавляем в корневой нод
        rootNode.addChildNode(emptyFloorAnimation2) //Добавляем в корневой нод
        
        heart = sceneOne.rootNode.childNode(withName: "Heart", recursively: true)!
        emptyHeart.addChildNode(heart) // Добавляем звезду в нод
        emptyHeart.scale = SCNVector3(allScale: 0.18)
        emptyHeart.position = SCNVector3(3, -0.9, 0)
        heart.position = SCNVector3(3, 0, 0)
        rootNode.addChildNode(emptyHeart) //Добавляем в корневой нод
        emptyHeart.physicsBody = SCNPhysicsBody.dynamic() // Устанавливаем статическое физическое тело
        emptyHeart.physicsBody!.categoryBitMask = ColliderCategory.Heart.rawValue // Устанавливаем битовую маску, которая будет определять категорию
        emptyHeart.physicsBody!.velocityFactor = SCNVector3(0,0,0) // В каких направлениях может двигаться обьект
        
        heart.runAction(SCNAction.repeatForever(SCNAction.rotate(by: 360 * CGFloat(Double.pi / 180) , around: SCNVector3(x: 0, y: 1, z: 0), duration: 3))) // Анимация вращения вокруг своей оси
        
        if #available(iOS 9.0, *){ // contactTestBitMask работает только на IOS 9+
            emptyHeart.physicsBody!.contactTestBitMask = ColliderCategory.Ball.rawValue // Устанавливаем взаимодействия звезды с персонажем, передаем битовую маску
        } else {
            emptyHeart.physicsBody!.collisionBitMask = ColliderCategory.Ball.rawValue
        }

        star = sceneOne.rootNode.childNode(withName: "Star", recursively: true)!
        emptyStar.addChildNode(star) // Добавляем звезду в нод
        emptyStar.scale = SCNVector3(allScale: 0.5)
        star.pivot = SCNMatrix4MakeTranslation(-0.6, 0, 0) // Сдвигаем точку узла в центр (Неправильно экспортировалось из Blender)
        
        emptyStar.position = SCNVector3(5, -0.8, 0) //(5, -1 ,0)
        star.position = SCNVector3(5, 0, 0)
        
        rootNode.addChildNode(emptyStar) //Добавляем в корневой нод
        //emptyStar.physicsBody?.isAffectedByGravity = true
        emptyStar.physicsBody = SCNPhysicsBody.dynamic() // Устанавливаем статическое физическое тело
        emptyStar.physicsBody!.categoryBitMask = ColliderCategory.Star.rawValue // Устанавливаем битовую маску, которая будет определять категорию
        emptyStar.physicsBody!.velocityFactor = SCNVector3(0,0,0) // В каких направлениях может двигаться обьект
        
        star.runAction(SCNAction.repeatForever(SCNAction.rotate(by: 360 * CGFloat(Double.pi / 180), around: SCNVector3(0, 1, 0), duration: 3))) // Анимация вращения вокруг своей оси
        
        if #available(iOS 9.0, *){ // contactTestBitMask работает только на IOS 9+
            emptyStar.physicsBody!.contactTestBitMask = ColliderCategory.Ball.rawValue // Устанавливаем взаимодействия звезды с персонажем, передаем битовую маску
        } else {
            emptyStar.physicsBody!.collisionBitMask = ColliderCategory.Ball.rawValue
        }
        
        shuriken = sceneOne.rootNode.childNode(withName: "Shuriken", recursively: true)!
        emptyShuriken.addChildNode(shuriken) // Добавляем сюрикен в нод
        emptyShuriken.scale = SCNVector3(allScale: 0.1)
        emptyShuriken.position = SCNVector3(2, -0.8, 0)
        shuriken.position = SCNVector3(2, 0, 0)
        rootNode.addChildNode(emptyShuriken) //Добавляем в корневой нод
        emptyShuriken.physicsBody = SCNPhysicsBody.kinematic() // Устанавливаем кинематическое физическое тело(Не затронуты физическими силами или столкновениями)
        emptyShuriken.physicsBody!.categoryBitMask = ColliderCategory.Shuriken.rawValue // Устанавливаем битовую маску, которая будет определять категорию
        
        shuriken.runAction(SCNAction.repeatForever(SCNAction.rotate(by: 360 * CGFloat(Double.pi / 180) , around: SCNVector3(x: 0, y: 0, z: 1), duration: 3))) // Анимация вращения вокруг своей оси
        
        if #available(iOS 9.0, *){ // contactTestBitMask работает только на IOS 9+
        emptyShuriken.physicsBody!.contactTestBitMask = ColliderCategory.Ball.rawValue // Устанавливаем взаимодействия сирюкена с персонажем, передаем битовую маску
        } else {
            emptyShuriken.physicsBody!.collisionBitMask = ColliderCategory.Ball.rawValue
        }
        
        ballScene = SCNScene(named: "art.scnassets/person/runFixed.dae")!
        ball = ballScene.rootNode.childNode(withName: "ball", recursively: true)!
        anim = ballScene.rootNode.childNode(withName: "anim", recursively: true)!
        epmtyCharacter.addChildNode(ball)
        epmtyCharacter.addChildNode(anim)

        epmtyCharacter.scale = SCNVector3(allScale: 0.1)
        epmtyCharacter.position = SCNVector3Make(-0.6, -1.18, 0)  // -0.8, -1.18
        epmtyCharacter.rotation = SCNVector4Make(0, 1, 0, .pi / 2)
        
        let charaterGeometry = SCNSphere(radius: 0.05) //(radius: 0.05)
        
        epmtyCharacter.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: charaterGeometry, options: nil))
        epmtyCharacter.physicsBody!.mass = 5
        epmtyCharacter.physicsBody!.velocityFactor = SCNVector3(0,1,0) // В каких направлениях может двигаться обьект
        epmtyCharacter.physicsBody!.angularVelocityFactor = SCNVector3Zero
        epmtyCharacter.physicsBody!.categoryBitMask = ColliderCategory.Ball.rawValue
        if #available(iOS 9.0, *){ // contactTestBitMask работает только на IOS 9+
            epmtyCharacter.physicsBody!.contactTestBitMask = ColliderCategory.Floor.rawValue | ColliderCategory.Shuriken.rawValue | ColliderCategory.Star.rawValue | ColliderCategory.Heart.rawValue// Устанавливаем взаимодействия персонажа с полом, звездой и сирюкеном, передаем битовую маску
        } else {
            epmtyCharacter.physicsBody!.collisionBitMask = ColliderCategory.Floor.rawValue | ColliderCategory.Shuriken.rawValue | ColliderCategory.Star.rawValue | ColliderCategory.Heart.rawValue
        }

        rootNode.addChildNode(epmtyCharacter)
    }
    func setupCameraAndLight(){
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 0) // Положение камеры
        cameraNode.pivot = SCNMatrix4MakeTranslation(0, 0, -3) //Сдвигаем у камеры точку опоры на 3 единицы по оси Z
        rootNode.addChildNode(cameraNode)
        
        let light = SCNLight() // Освещение для оси X
        light.type = .spot // Конусообразная область освещения
        light.spotOuterAngle = 90
        light.attenuationStartDistance = 0.0 // Расстояние от света, в котором его интенсивность уменьшается
        light.attenuationFalloffExponent = 2 // Кривая перехода для интенсивности света между ее затуханием
        light.attenuationEndDistance = 30.0 // Расстояние от света, в котором полностью уменьшена его интенсивность
        
        let lightNodeSpot = SCNNode()
        lightNodeSpot.light = light
        lightNodeSpot.position = SCNVector3(0, 10, 1)
        rootNode.addChildNode(lightNodeSpot)
        
        let lightNodeFront = SCNNode() // Источник света впереди сцены
        lightNodeFront.light = light
        lightNodeFront.position = SCNVector3(0, 1, 15)
        rootNode.addChildNode(lightNodeFront)
        
        //Направляем источники света, которые создали, в центр
        let center = SCNNode()
        center.position = SCNVector3Zero //по центру ставим
        rootNode.addChildNode(center)
        
        lightNodeSpot.constraints = [SCNLookAtConstraint(target: center)] // чтобы источник указывал на нужный нод
        lightNodeFront.constraints = [SCNLookAtConstraint(target: center)]
        cameraNode.constraints = [SCNLookAtConstraint(target: center)]
        
        //Источник света для общей яркости сцены
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light!.type = .ambient
        ambientLight.light!.color = UIColor(white: 0.5, alpha: 1.0)
        rootNode.addChildNode(ambientLight)
    }
    func setupFloor(){
        let floorGeometry = SCNBox(width: 4, height: 0.5, length: 0.4, chamferRadius: 0) // Создаем геометрию пола
        
        let materialFloorGeometry = SCNMaterial() // Создаем материал для пола
        materialFloorGeometry.emission.contents = UIImage(named: "Floor2") //emission - яркие цвета излучаются сильнее всего
        materialFloorGeometry.multiply.contents = UIColor.green //multiply - применяется для раскраски
        floorGeometry.firstMaterial = materialFloorGeometry // Передаем материал геометрии пола
        
        let floor = SCNNode(geometry: floorGeometry)
        let emptyFloor = SCNNode() // Родительский нод земли
        emptyFloor.addChildNode(floor)
        emptyFloor.position.y = -1.63 // Позиция пола по высоте, остальные 0, 0
        rootNode.addChildNode(emptyFloor) // Добавляем родительский нод в корневой
        
        let collideFloor = SCNNode(geometry: floorGeometry) // Создаем клон пола
        collideFloor.opacity = 0 // Значение непрозрачности узла, чтобы был невидимый
        collideFloor.physicsBody = SCNPhysicsBody.kinematic()
        collideFloor.physicsBody!.mass = 1000
        collideFloor.physicsBody!.categoryBitMask = ColliderCategory.Floor.rawValue
        if #available(iOS 9.0, *){ // contactTestBitMask работает только на IOS 9+
            collideFloor.physicsBody!.contactTestBitMask = ColliderCategory.Ball.rawValue // Устанавливаем взаимодействия земли с персонажем, передаем битовую маску
        } else {
            collideFloor.physicsBody!.collisionBitMask = ColliderCategory.Ball.rawValue
        }
        collideFloor.position.y = -1.33
        rootNode.addChildNode(collideFloor)
    }

    var number = 2
    var change = true
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) { // Здесь описывается логика движения пола

        let nodes = [emptyShuriken, emptyHeart, emptyStar]
        if(change == true){ // Если нод еще не закончил бег
        var dt:Double // Промежуток времени
        if runOfFloor == true{
            if let lt = timeLast{ // Если timeLast содержит значение, то
                dt = time - lt // Из настоящего времени вычитаем прошлое (в секундах). Получаем промежуток времени
            } else{ // Если timeLast пуст, то
                dt = 0
            }
        } else{
            dt = 0
        }
        timeLast = time // Записываем время в настоящий момент
            moveNode(node: emptyFloorAnimation1, dt: dt)
            moveNode(node: emptyFloorAnimation2, dt: dt)
            moveNode(node: nodes[number], dt: dt)
        }else{ //Если нод закончил свой бег, меняем
            if (nodes[number] == emptyHeart){ // Если предыдущий нод был Heart(здоровье), меняем его на другой, не повторяя
                while (nodes[number] == emptyHeart){
                    number = Int.random(in: 0...2)
                }
                change = true
            }else{
                number = Int.random(in: 0...2)
                change = true
            }
        }
    }
    
    func moveNode(node: SCNNode, dt: Double){
        node.position.x += Float(dt * speedFloor) // Меняем позицию нода по x
        if (node.position.x <= -5.5) {
            node.position.x = 5.5 //4.5
            if ((node == emptyStar) || (node == emptyShuriken) || (node == emptyHeart)){
                speedFloor += -0.1 // Увеличиваем скорость бега
                change = false
                node.isHidden = false // Делаем видимым
            }
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) { //  В этом методе контролируется поведение тел при столкновении, как только они вступят в контакт
        if isCollision(firstNode: ColliderCategory.Ball, secondNode: ColliderCategory.Shuriken, contact: contact){
                if(GameViewController.overlay?.scoreHeartNumber == 1){
                    let data = UserDefaults.standard.integer(forKey: "score")
                    if data < GameViewController.overlay!.scoreNumber{
                        UserDefaults.standard.set(GameViewController.overlay!.scoreNumber, forKey: "score") // Если побили рекорд то записываем
                    }
                GameViewController.overlay?.bestScoreLabel.text = String(UserDefaults.standard.integer(forKey: "score"))
                GameViewController.overlay?.reduceScoreHeartLabel()
                runOfFloor = false // Останавливаем движение пола
                triggered = true
                GameViewController.overlay!.addReplayButton()
                ball.removeAllActions() // останавливаем все действия шара
                shuriken.removeAllActions()
                ball.removeFromParentNode()
                anim.removeFromParentNode()
                    
                ballScene = SCNScene(named: "art.scnassets/person/dieFixed.dae")!
                    
                ball = ballScene.rootNode.childNode(withName: "ball", recursively: true)!
                anim = ballScene.rootNode.childNode(withName: "anim", recursively: true)!
                epmtyCharacter.addChildNode(ball)
                epmtyCharacter.addChildNode(anim)
                    
                let opasityCharacter = SCNAction.fadeOpacity(to: 0, duration: 4.6)
                ball.runAction(opasityCharacter)
                }else{
                    emptyShuriken.isHidden = true
                    GameViewController.overlay?.reduceScoreHeartLabel()
                }
        }
        
        if isCollision(firstNode: ColliderCategory.Ball, secondNode: ColliderCategory.Star, contact: contact){
            if let overlay = GameViewController.overlay{
                emptyStar.isHidden = true // Скрываем эту звезду при прикосновении
                overlay.upcdateScoreLabel() // На экране появляется лейбл с числом очков
            }
        }
        if isCollision(firstNode: ColliderCategory.Ball, secondNode: ColliderCategory.Heart, contact: contact){
            if let overlay = GameViewController.overlay{
                emptyHeart.isHidden = true // Скрываем эту сердце при прикосновении
                if(overlay.scoreHeartNumber < 3){
                overlay.upcdateScoreHeartLabel() // На экране появляется лейбл с числом жизней
            }
        }
        
        }
    }
    func isCollision(firstNode: ColliderCategory, secondNode: ColliderCategory, contact: SCNPhysicsContact)->Bool{ // Проверяет столкнулись ли тела
        let firstANode = contact.nodeA.physicsBody!.categoryBitMask == firstNode.rawValue
        let secondANode = contact.nodeA.physicsBody!.categoryBitMask == secondNode.rawValue
        
        let firstBNode = contact.nodeB.physicsBody!.categoryBitMask == firstNode.rawValue
        let secondBNode = contact.nodeB.physicsBody!.categoryBitMask == secondNode.rawValue
        
        if ((firstANode && secondBNode)||(secondANode && firstBNode)){
            return true
        }else{
            return false
        }
    }
}
extension SCNVector3 { // Расширение для одинаковых значений
    init(allScale: Float){
        self.init()
        self.x = allScale
        self.y = allScale
        self.z = allScale
    }
}
