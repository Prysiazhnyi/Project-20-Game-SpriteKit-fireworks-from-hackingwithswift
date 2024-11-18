//
//  GameScene.swift
//  Project-20-Game-SpriteKit-fireworks
//
//  Created by Serhii Prysiazhnyi on 18.11.2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()

    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var fireworksCount = 0

    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
            background.position = CGPoint(x: 512, y: 384)
            background.blendMode = .replace
            background.zPosition = -1
            addChild(background)

            gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 50, y: 50)
        scoreLabel.zPosition = 500
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        // 1
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)

        // 2
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)

        // 3
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan

        case 1:
            firework.color = .green

        case 2:
            firework.color = .red

        default:
            break
        }

        // 4
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))

        // 5
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)

        // 6
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }

        // 7
        fireworks.append(node)
        addChild(node)
    }
   
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        fireworksCount += 1
        print("fireworksCount --- \(fireworksCount)")
        
        if fireworksCount == 3 {
            gameTimer?.invalidate()
           gemeover()
        }

        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)

        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

        default:
            break
        }
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue }
            
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }

                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        // Если игра закончена, проверяем, была ли нажата кнопка перезапуска
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if isGameOver {
            let hitNodes = nodes(at: location).filter { $0.name == "startNewGameButton" }
            
            if let _ = hitNodes.first {
                // Перезапускаем игру, если нажата кнопка
                restartGame()
            }
        }
        checkTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }

    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                // this uses a position high above so that rockets can explode off screen
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            
            // Последовательность действий
                   let wait = SKAction.wait(forDuration: 2.0) // Время на завершение эффекта
                   let remove = SKAction.removeFromParent()
                   let sequence = SKAction.sequence([wait, remove])
                   
                   emitter.run(sequence) // Запуск последовательности на излучателе
        }

        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0

        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }

            if firework.name == "selected" {
                // destroy this firework!
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }

        switch numExploded {
        case 0:
            // nothing – rubbish!
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    func gemeover() {

        run(SKAction.playSoundFileNamed("Ha-Ha.m4a", waitForCompletion: false))
        
        // Создаем узел для отображения текста "Game Over"
        let gameOverTitle = SKSpriteNode(imageNamed: "game-over")
        gameOverTitle.position = CGPoint(x: size.width / 2, y: size.height / 1.4) // Центр сцены
        gameOverTitle.alpha = 0
        gameOverTitle.setScale(2) // Увеличенный начальный масштаб
        
        // Создаем анимации
        let fadeIn = SKAction.fadeIn(withDuration: 0.3) // Плавное появление
        let scaleDown = SKAction.scale(to: 1, duration: 0.3) // Уменьшение масштаба до 1
        let group = SKAction.group([fadeIn, scaleDown]) // Одновременное выполнение
        
        //        // Запускаем анимацию
        gameOverTitle.run(group)
        gameOverTitle.zPosition = 900 // Слой поверх всех элементов
        addChild(gameOverTitle) // Добавляем узел на сцену
        
        // Вызываем кастомное окно оповещения
        showCustomAlert()
        
        // системный алерт
        //        // Получаем доступ к текущему представлению и его контроллеру
        //        if let view = self.view, let viewController = view.window?.rootViewController {
        //            // Создаем UIAlertController
        //            let ac = UIAlertController(
        //                title: "Your score: \(score)",
        //                message: "Press OK to start the game again",
        //                preferredStyle: .alert
        //            )
        //            // Действие по нажатию "OK" для сброса и перезапуска игры
        //            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
        //                guard let self = self else { return }
        //                // Сброс всех игровых значений
        //                self.score = 0
        //                self.isGameOver = false
        //                self.targetSpeed = 4.0
        //                self.targetDelay = 0.8
        //                self.targetsCreated = 0
        //
        //                // Удаляем все дочерние узлы на сцене
        //                self.removeAllChildren()
        //                self.timeRemaining = 60
        //
        //                timer()
        //                bulletsInClip = 3
        //                createBackground()
        //                createOverlay()
        //                levelUp()
        //            })
        //            // Отображаем UIAlertController
        //            viewController.present(ac, animated: true)
        //        }
        
    }
    
    func showCustomAlert() {
        // Создаем фон для окна оповещения
        let alertBackground = SKSpriteNode(color: .black, size: CGSize(width: 400, height: 200))
        alertBackground.position = CGPoint(x: size.width / 2, y: size.height / 2)
        alertBackground.alpha = 0.5  // Прозрачность фона
        alertBackground.zPosition = 1000  // Слой поверх других элементов
        addChild(alertBackground)
        
        // Создаем текст с результатами игры
        let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.fontSize = 30
        scoreLabel.text = "Your score: \(score)"
        scoreLabel.position = CGPoint(x: 0, y: 40)
        scoreLabel.zPosition = 1001
        alertBackground.addChild(scoreLabel)
        
        // Создаем текст с предложением начать игру заново
        let messageLabel = SKLabelNode(fontNamed: "Chalkduster")
        messageLabel.fontSize = 25
        messageLabel.text = "Press OK to start again"
        messageLabel.position = CGPoint(x: 0, y: -20)
        messageLabel.zPosition = 1001
        alertBackground.addChild(messageLabel)
        
        // Создаем кнопку для начала новой игры
        let button = SKSpriteNode(color: .green, size: CGSize(width: 200, height: 50))
        button.position = CGPoint(x: 0, y: -70)
        button.zPosition = 1001
        button.name = "startNewGameButton"  // Добавляем имя кнопке для упрощенного обнаружения
        alertBackground.addChild(button)
        
        // Добавляем текст на кнопку
        let buttonText = SKLabelNode(fontNamed: "Chalkduster")
        buttonText.fontSize = 20
        buttonText.text = "Start New Game"
        buttonText.position = CGPoint(x: 0, y: 0)
        buttonText.zPosition = 1002
        button.addChild(buttonText)
    }
    
    func restartGame() {
        // Создаем новую сцену
        let newScene = GameScene(size: self.size)
        newScene.scaleMode = self.scaleMode

        // Переход на новую сцену с анимацией (опционально)
        let transition = SKTransition.fade(withDuration: 1.0)
        self.view?.presentScene(newScene, transition: transition)
    }
}
