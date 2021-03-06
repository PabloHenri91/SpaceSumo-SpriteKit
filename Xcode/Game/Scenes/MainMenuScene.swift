//
//  MainMenuScene.swift
//  Game
//
//  Created by Pablo Henrique Bertaco on 2/17/16.
//  Copyright © 2016 Pablo Henrique Bertaco. All rights reserved.
//

import SpriteKit

class MainMenuScene: GameScene {
    
    enum states : String {
        //Estado principal
        case mainMenu
        
        //Estados de saida da scene
        case options
        case credits
        case hangar
        case connect
        case connecting
    }
    
    //Estados iniciais
    var state = states.mainMenu
    var nextState = states.mainMenu
    
    //buttons
    var buttonPlay:Button!
    var buttonOfflineMode:Button!
    
    var labelConnectStatus:Label!
    
    var serverManager:ServerManager! //Por seguranca o serverManager nao deve ser iniciado ainda.
    
    var connectTime: NSTimeInterval = 0
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        
        self.addChild(Control(textureName: "background", z:-1000, xAlign: .center, yAlign: .center))
        
        self.buttonPlay = Button(textureName: "buttonYellow", icon: "play", x: 192, y: 120, xAlign: .center, yAlign: .center)
        self.addChild(self.buttonPlay)
        
        self.buttonOfflineMode = Button(textureName: "buttonGray", text:"offline mode", x:192, y:228, xAlign: .center, yAlign: .down)
        self.addChild(self.buttonOfflineMode)
        self.buttonOfflineMode.hidden = true
        
        //Serve para setar o foco inicial no tvOS
        GameScene.selectedButton = self.buttonPlay
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        super.update(currentTime)
        
        //Estado atual
        if(self.state == self.nextState) {
            switch (self.state) {
                
            case states.connecting:
                
                if self.buttonOfflineMode.hidden == true {
                    if currentTime - self.connectTime > 3 {
                        self.buttonOfflineMode.hidden = false
                        GameScene.selectedButton = self.buttonOfflineMode
                    }
                }
                
                break
                
            default:
                break
            }
        }  else {
            self.state = self.nextState
            
            //Próximo estado
            switch (self.nextState) {
            case states.hangar:
                
                let scene = HangarScene()
                self.view?.presentScene(scene, transition: self.transition)
                break
            case states.connect:
                
                self.connectTime = currentTime
                
                let box = Control(textureName: "boxWhite128x64", x:176, y:103, xAlign:.center, yAlign:.center)
                box.zPosition = box.zPosition * 4
                self.labelConnectStatus = Label(text: "connecting to server...", x:64, y:32)
                box.addChild(self.labelConnectStatus)
                self.addChild(box)
                
                self.nextState = states.connecting
                self.state = states.connecting
                
                self.setHandlers()
                
                self.serverManager.socket.connect(timeoutAfter: 10, withTimeoutHandler: { [weak self] in
                    guard let scene = self else { return }
                    scene.labelConnectStatus.setText("connection timed out")
                    scene.serverManager.disconnect()
                    })
                
                break
                
            case states.connecting:
                fatalError()// nao pode ter preparacao para troca deste estado
                break
                
            default:
                break
            }
        }
    }
    
    func setHandlers() {
        self.serverManager = ServerManager.sharedInstance
        
        self.serverManager.socket.onAny { [weak self] (socketAnyEvent:SocketAnyEvent) -> Void in
            
            //print(socketAnyEvent.description)
            
            guard let scene = self else { return }
            
            switch scene.state {
                
            case states.connecting:
                switch(socketAnyEvent.event) {
                    
                case "error":
                    scene.buttonOfflineMode.hidden = false
                    GameScene.selectedButton = scene.buttonOfflineMode
                    break
                    
                case "connect":
                    scene.labelConnectStatus.parent?.removeFromParent()
                    //Troca de scene
                    scene.nextState = states.hangar
                    scene.serverManager.socket.emit("userDisplayInfo", scene.serverManager.userDisplayInfo.displayName!)
                    break
                    
                case "reconnect":
                    scene.buttonOfflineMode.hidden = false
                    GameScene.selectedButton = scene.buttonOfflineMode
                    break
                    
                case "reconnectAttempt":
                    scene.labelConnectStatus.setText("Reconnect Attempt:  " + (ServerManager.sharedInstance.socket.reconnectAttempts + 1 - (socketAnyEvent.items?.firstObject as! Int)).description)
                    break
                    
                case "disconnect":
                    scene.labelConnectStatus.setText("connection timed out")
                    break
                    
                default:
                    print(socketAnyEvent.event + " nao foi processado em MainMenuScene " + scene.state.rawValue)
                    break
                }
                
                break
                
            default:
                print(socketAnyEvent.event + " recebido fora do estado esperado em MainMenuScene " + scene.state.rawValue)
                break
            }
        }
    }
    
    override func touchesEnded(taps touches: Set<UITouch>) {
        super.touchesEnded(taps: touches)
        
        //Estado atual
        if(self.state == self.nextState) {
            for touch in touches {
                switch (self.state) {
                case states.mainMenu:
                    if(self.buttonPlay.containsPoint(touch.locationInNode(self))) {
                        self.nextState = states.connect
                        return
                    }
                    break
                    
                case states.connecting:
                    if(self.buttonOfflineMode.containsPoint(touch.locationInNode(self))) {
                        self.nextState = states.hangar
                        return
                    }
                    break
                    
                default:
                    break
                }
            }
        }
    }
    
    #if os(tvOS)
    override func pressBegan(press: UIPress) -> Bool {
        
        switch press.type {
        case .Menu:
            return true
            
        case .Select:
            self.touchesEnded(taps: Set<UITouch>([UITouch()]))
            break
        default:
            break
        }
        
        return false
    }
    #endif
}
