//
//  RoomCell.swift
//  Game
//
//  Created by Pablo Henrique Bertaco on 3/18/16.
//  Copyright © 2016 Pablo Henrique Bertaco. All rights reserved.
//

import SpriteKit

class RoomCell: Control {
    
    var roomId:String
    
    
    var buttonJoin:Button!
    var labelName0:Label!
    var labelName1:Label!
    var labelName2:Label!
    
    init(roomId:String, names:[String], x:Int = 0, y:Int = 0, xAlign:Control.xAlignments = .left, yAlign:Control.yAlignments = .up) {
        self.roomId = roomId
        super.init(textureName: "boxWhite337x105", x:x, y:y, xAlign:xAlign, yAlign:yAlign)
        
        self.buttonJoin = Button(textureName: "buttonYellow", text:"join", x: 230, y: 64, xAlign: .left, yAlign: .up)
        self.addChild(self.buttonJoin)
        
        var i = 0
        for name in names {
            switch i {
                
            case 0:
                self.labelName0 = Label(text: name, x:54, y:15, xAlign: .left, yAlign: .up)
                self.addChild(self.labelName0)
                break
            case 1:
                self.labelName1 = Label(text: name, x:118, y:32, xAlign: .left, yAlign: .up)
                self.addChild(self.labelName1)
                break
            case 2:
                self.labelName2 = Label(text: name, x:182, y:15, xAlign: .left, yAlign: .up)
                self.addChild(self.labelName2)
                break
                
            default:
                print("Nome inesperado s;")
                break
            }
            i++
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
