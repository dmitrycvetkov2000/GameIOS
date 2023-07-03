//
//  menu.swift
//  Course
//
//  Created by Дмитрий Цветков on 11.03.2022.
//

import UIKit
import SceneKit
class Menu: SCNScene, SCNSceneRendererDelegate {
    let emptyFloorAnimation1 = SCNNode() // Пустой нод, куда будем добавлять основные ноды
    
    let epmtyCharacter = SCNNode()
    var ball = SCNNode()
    
    convenience init(create: Bool) { //Вспомогательный инициализатор
        self.init()
        setupCameraAndLight()
        setupFloor()

        let sceneOne = SCNScene(named: "art.scnassets/Scene11.dae")! // Объявляем сцену
        
        emptyFloorAnimation1.scale = SCNVector3(allScale: 0.1) // Уменьшаем размер нода, используя расширение
        emptyFloorAnimation1.position = SCNVector3(0, -1.2, 0) // Устанавливаем позицию нода(Накладываем поверх неподвижного пола)
        
        let floorAnimation1 = sceneOne.rootNode.childNode(withName: "FloorAnimation", recursively: true)! // Записываем пол в эту переменную из сцены
        floorAnimation1.position = SCNVector3(0, 0, 0)
        
        emptyFloorAnimation1.addChildNode(floorAnimation1) // Добавляем в пустой нод нод пола
        rootNode.addChildNode(emptyFloorAnimation1) //Добавляем в корневой нод
                
        let ballScene = SCNScene(named: "art.scnassets/person/WavingFixed.dae")!
        ball = ballScene.rootNode.childNode(withName: "ball", recursively: true)!
        let anim = ballScene.rootNode.childNode(withName: "anim", recursively: true)!
        epmtyCharacter.addChildNode(ball)
        epmtyCharacter.addChildNode(anim)
        
        ball.scale = SCNVector3(allScale: 0.1)
        epmtyCharacter.scale = SCNVector3(allScale: 0.1)
        epmtyCharacter.position = SCNVector3(-0.6, -1, 0)
        
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
    }
}
