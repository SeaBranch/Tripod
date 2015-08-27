//
//  GameScene.swift
//  testingOutShapes
//
//  Created by NathanWSjoquist on 8/18/15.
//  Copyright (c) 2015 Nathan Sjoquist. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene {
    var spherePoints = Array<CGPoint>()
    /*var spherePoints = [CGPointMake(300,135),CGPointMake(230,320), CGPointMake(315,510),CGPointMake(215,630),
        CGPointMake(270,710),CGPointMake(230,680), CGPointMake(315,810),CGPointMake(210,910), CGPointMake(140, 1010),
        CGPointMake(350, 250),CGPointMake(200, 450),CGPointMake(235, 575),CGPointMake(130, 760),CGPointMake(250, 990),
        CGPointMake(130, 1100),CGPointMake(350, 1150),CGPointMake(650, 1050),CGPointMake(800, 1150),CGPointMake(680, 1300),
        CGPointMake(760, 1480),CGPointMake(630, 1390),CGPointMake(400, 1500),CGPointMake(276, 1710),CGPointMake(375, 1920)]
    //= [CGPointMake(260, 670),CGPointMake(260, 370),CGPointMake(460, 170),CGPointMake(260, 1070),]
//    let arrayPoints = [CGPointMake(300,135),CGPointMake(230,320), CGPointMake(315,510),CGPointMake(215,630),
//        CGPointMake(270,710),CGPointMake(230,680), CGPointMake(315,810),CGPointMake(210,910), CGPointMake(140, 1010),
//        CGPointMake(350, 250),CGPointMake(200, 450),CGPointMake(235, 575),CGPointMake(130, 760),CGPointMake(250, 990),
//        CGPointMake(130, 1100),CGPointMake(350, 1150),CGPointMake(650, 1050),CGPointMake(800, 1150),CGPointMake(680, 1300),
//        CGPointMake(760, 1480),CGPointMake(630, 1390),CGPointMake(400, 1500),CGPointMake(276, 1710),CGPointMake(375, 1920)]
//
*/
    
    var sphereNodes = Array<SKSpriteNode>()
    
    var arm1Source:String?
    var arm2Source:String?
    var arm3Source:String?
    
    let pullStrength:Float = 4.2
    var stopPresentation = false
    override func didMoveToView(view: SKView) {
        //view.showsPhysics = true
        self.backgroundColor = UIColor(red: 0.2, green: 0, blue: 0.2, alpha: 1)
        self.beginEnemyInvasion()
        self.addSpheresToScene()
    }
    func addSpheresToScene(){
        if stopPresentation{
            return
        }
        
        var sphereNum:Int = 2
        let sphereNode1:SKSpriteNode = childNodeWithName("Sphere1") as! SKSpriteNode
        self.sphereNodes.append(sphereNode1)
//        let field1 = sphereNode1.childNodeWithName("field") as! SKFieldNode
//        field1.strength = pullStrength
//        field1.falloff = 0
//        field1.categoryBitMask = uint(self.maskForArm(1))
//        self.arm1Source = sphereNode1.name
        
        self.spherePoints = generateMapFromPoint(sphereNode1.position)
        var firstLoop = true
        for pt:CGPoint in self.spherePoints{
            if sphereNum == self.spherePoints.count{
                let goal = childNodeWithName("Goal")!
                goal.position = pt
            }else if firstLoop{
                firstLoop = false

            }else{
            let nextSphereNode = sphereNode1.copy() as! SKSpriteNode
            nextSphereNode.name = "Sphere\(sphereNum)"
            nextSphereNode.position = pt
            self.addChild(nextSphereNode)
            self.sphereNodes.append(nextSphereNode)
            let field = nextSphereNode.childNodeWithName("field") as! SKFieldNode
            field.strength = pullStrength
            field.falloff = 0
            field.categoryBitMask = 0
            
            sphereNum+=1
            }
        }
        self.attachArmToSphere(1, sphere: sphereNode1)

    }
    
    func distPtToPt(pt1:CGPoint, pt2:CGPoint)->CGFloat{
        let offX = pt2.x - pt1.x
        let offY = pt2.y - pt1.y
        
        return hypot(offY, offX)
    }
    
    
    func generateMapFromPoint(pt:CGPoint)->Array<CGPoint>{
        
        var newSpherePoints = Array<CGPoint>()
        newSpherePoints.append(pt)
        var start = pt
        var badPtInARow = 0
        while newSpherePoints.count < 100{
            
            let rndX:CGFloat = CGFloat(arc4random()%100) + 120.0
            let multX:CGFloat = (arc4random()%2 == 1) ? 1:-1
            let rndY:CGFloat = CGFloat(arc4random()%100) + 120.0
            let multY:CGFloat = (arc4random()%2 == 1) ? 1:-1
            
            let offX = rndX * multX
            let offY = rndY * multY
            let newPt = CGPoint(x:start.x + offX, y: start.y + offY)
            
            var goodPt = true
            
//            if currentFailCount > 50{
//                currentFailCount = 0
//                let ind = Int(arc4random()%UInt32(self.sphereNodes.count))
//                start = (self.sphereNodes[ind] as SKSpriteNode).position
//            }
            
            for p in newSpherePoints{
                if !(distPtToPt(p, pt2: newPt) > 150){
                    goodPt = false

                    break
                }
//                }else if newPt.x > 1200 || newPt.x < 0 || newPt.y > 1200 || newPt.y < 0{
//                    goodPt = false
//                    print(" bad point ")
//
//                    break
//                }
            }
            if goodPt{
                newSpherePoints.append(newPt)
                start = newPt
                print(" good point ")
                badPtInARow = 0
                
            }else{

                badPtInARow+=1
                print("bad point \(badPtInARow)")
                if badPtInARow > 80{
                    //newSpherePoints.removeAll(keepCapacity: false)
                    badPtInARow = 0
                    start = newSpherePoints[newSpherePoints.count/2]
                    break
                }
            }
        }
        return newSpherePoints
    }
    
    func removeArmFromSphere(sphere:SKSpriteNode){
        if stopPresentation{
            return
        }
        let field = sphere.childNodeWithName("field") as! SKFieldNode
        field.strength = pullStrength
        field.falloff = 0
        field.categoryBitMask = 0
    }
    
    func maskForArm(num:Int)->Int{
        switch num{
        case 1,2:
            return num
        case 3:
            return 4
        default:
            return 0
        }
        return 0
    }
    
    func attachArmToSphere(armNum:Int,sphere:SKSpriteNode){
        if stopPresentation{
            return
        }
        let field = sphere.childNodeWithName("field") as! SKFieldNode
        field.strength = pullStrength
        field.falloff = 0
        field.categoryBitMask = uint(self.maskForArm(armNum))
        switch armNum{
        case 1:
            self.arm1Source = sphere.name
        case 2:
            self.arm2Source = sphere.name
        case 3:
            self.arm3Source = sphere.name
        default:
            ""
        }
    }
    func requestArmForSKNode(node:SKSpriteNode){
        if self.arm1Source == nil{
            self.attachArmToSphere(1, sphere: node)
        }else if self.arm2Source == nil{
            self.attachArmToSphere(2, sphere: node)
        }else if self.arm3Source == nil{
            self.attachArmToSphere(3, sphere: node)
        }
    }
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        
        for touch in (touches as! Set<UITouch>) {
            let location = touch.locationInNode(self)
            
            for sprt in self.sphereNodes{
                
                if sprt.containsPoint(location){
                    let field = sprt.childNodeWithName("field") as! SKFieldNode
                    field.strength = pullStrength
                    field.falloff = 0
                    field.categoryBitMask = 0
                    if sprt.name == self.arm1Source{
                        self.arm1Source = nil
                    }else if sprt.name == self.arm2Source{
                        self.arm2Source = nil
                    }else if sprt.name == self.arm3Source{
                        self.arm3Source = nil
                    }else{
                        self.requestArmForSKNode(sprt)
                    }
                    
                }
            }//
//            sprite.xScale = 0.5
//            sprite.yScale = 0.5
//            sprite.position = location
//            
//            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
//            
//            sprite.runAction(SKAction.repeatActionForever(action))
//            
//            self.addChild(sprite)
        }
    }
    
    
    func clearScene(){
        stopPresentation = true
        for sp in sphereNodes{
            sp.removeAllActions()
            sp.removeAllChildren()
            sp.removeFromParent()
        }
        for en in enemyArray{
            en.removeAllActions()
            en.removeAllChildren()
            en.removeFromParent()
        }
        for remaining in self.children{
            remaining.removeAllActions()
            remaining.removeAllChildren()
            remaining.removeFromParent()
        }
        
        sphereNodes.removeAll(keepCapacity: false)
        //sphereNodes = []
        arm1Source = nil
        arm2Source = nil
        arm3Source = nil
        
        self.enemyArray.removeAll(keepCapacity: false)
        //self.enemyArray = []
//        removeAllChildren()

    }
    func signalDeath(){
        self.clearScene()
        
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "YouDiedNote", object: nil))
    }
    func signalWin(){
        self.clearScene()

        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "YouLivedNote", object: nil))
    }
    
    func centerOnNode(node: SKNode) {
        let nodPt = node.position
        let nodPtToScX = -((nodPt.x/self.size.width)-0.5)
        let nodPtToScY = -((nodPt.y/self.size.height)-0.5)
        self.anchorPoint = CGPoint(x: nodPtToScX, y: nodPtToScY)
        
       // node.parent!.position =
           //let thing = CGPoint(x:node.parent!.position.x - cameraPositionInScene.x, y:node.parent!.position.y - cameraPositionInScene.y)
    }
   
    func lookAtGoal(){
        if stopPresentation{
            return
        }
        print("\nlook at goal\n")
        let body = childNodeWithName("Body") as! SKSpriteNode
        let bodyCenter = CGPoint(x: (body.size.width/2) * body.xScale, y: (body.size.height/2) * body.yScale)
        
        let eyestalk = body.childNodeWithName("EyeStalk")as! SKSpriteNode
        let eyeWhite = eyestalk.childNodeWithName("white")as! SKSpriteNode
        let eyeBall = eyeWhite.childNodeWithName("ball")as! SKSpriteNode
//        
        let goal = childNodeWithName("Goal")as! SKSpriteNode
        //let goal = childNodeWithName("testTarget")as! SKSpriteNode
        let offX = goal.position.x - body.position.x
        let offY = goal.position.y - body.position.y
        let hyp = hypot(offX, offY)
        
        let normal = CGPoint(x: offX/hyp, y: offY/hyp)
        
        let fifthEye = (eyestalk.size.width/5) * eyestalk.xScale
        let fourthWhite = (eyestalk.size.width/4) * eyeWhite.xScale
        
        let halfEye = (eyestalk.size.width/2) * eyestalk.xScale
        let halfWhite = (eyestalk.size.width/2) * eyeWhite.xScale
        
        let eyeWhiteToStalk = eyestalk.size.width / eyeWhite.size.width
        let eyeBallToWhite = eyeWhite.size.width / eyeBall.size.width
        
        eyestalk.anchorPoint = CGPoint(x:0.5 + (0.5 * normal.x), y:0.5 + (0.5 * normal.y))
        eyeWhite.anchorPoint = CGPoint(x:0.5 + (1.2 * normal.x * eyeWhiteToStalk), y:0.5 + (1.2 * normal.y * eyeWhiteToStalk))
        eyeBall.anchorPoint = CGPoint(x:0.5 + (0.6 * normal.x * eyeBallToWhite), y:0.5 + (0.6 * normal.y * eyeBallToWhite))
        //eyeWhite.anchorPoint = CGPoint(x:1 - (0.2 * normal.x), y:1 - (0.2 * normal.y))
        //eyeBall.anchorPoint = CGPoint(x: 0.5 + (0.3 * normal.x), y:0.5 + (0.3 * normal.y))
       // eyeWhite.anchorPoint = CGPoint(x:1.3, y:1.3)
        //eyeBall.anchorPoint = CGPoint(x: 2.45, y:2.45)
        
        eyestalk.zRotation =  (-body.zRotation) + CGFloat(M_PI)
//        eyeWhite.zRotation = -CGFloat(M_PI)
//        eyeBall.zRotation = CGFloat(M_PI)
        //eyeBall.zRotation =  -CGFloat(M_PI)
        //eyestalk.position = CGPoint(x: bodyCenter.x + (normal.x * (halfEye * 1.2)), y: bodyCenter.y + (normal.y * (halfEye * 1.2)))
        //eyeWhite.position = CGPoint(x: halfEye + (normal.x * fifthEye), y: halfEye + (normal.y * fifthEye))
        //eyeBall.position = CGPoint(x: halfWhite + (normal.x * fourthWhite), y: halfWhite + (normal.y * fourthWhite))
        
        if hyp < 150{
            self.stopPresentation = true
            self.signalWin()
        }
    }
    override func didSimulatePhysics() {
        if stopPresentation{
            return
        }
        self.lookAtGoal()
        
        if (NSDate().timeIntervalSinceDate(lastEnemyDate)) > enemySchedule[enemyProgress]{
            lastEnemyDate = NSDate()
            self.addNextEnemy()
            if enemyProgress < (enemySchedule.count - 1){
                enemyProgress+=1
            }
        }
        
        for enemy:SKSpriteNode in self.enemyArray{
            let body = childNodeWithName("Body") as! SKSpriteNode
            enemy.physicsBody!.applyForce(CGVector(dx: (body.position.x - enemy.position.x), dy: (body.position.y - enemy.position.y)))
        }
        /* Called before each frame is rendered */
        if let body = childNodeWithName("Body"){
            self.centerOnNode(body)
            if arm1Source != nil{
                let armNode = childNodeWithName("arm1") as! SKSpriteNode
                let bodyNode = childNodeWithName("Body")!
                let leftNode = bodyNode.childNodeWithName("topCircle")!
                let sourcePt = childNodeWithName(arm1Source!)!.position
                
                armNode.position = sourcePt
                let destPt = bodyNode.convertPoint(leftNode.position, toNode: self)
                
                let xD = destPt.x - sourcePt.x
                let yD = destPt.y - sourcePt.y
                
                let dir:CGFloat = atan2(yD, xD)
                
                let len = hypot(yD, xD)
                let armLen = len+30
                
                armNode.zRotation = ( dir - ((90 + 45)/2)) - 0.05/// (CGFloat(M_PI) * 2) ) // CGFloat(M_PI_2)
                armNode.size.height = armLen
                let keepTen = 30/armLen
                armNode.anchorPoint = CGPoint(x: 0.5, y: 1-keepTen)
            }else{
                let armNode = childNodeWithName("arm1") as! SKSpriteNode
                let bodyNode = childNodeWithName("Body")!
                let topNode = bodyNode.childNodeWithName("topCircle")!
                armNode.position = topNode.position
                armNode.size.height = 0
            }
            
            if arm2Source != nil{
                let armNode = childNodeWithName("arm2") as! SKSpriteNode
                let bodyNode = childNodeWithName("Body")!
                let leftNode = bodyNode.childNodeWithName("leftCircle")!
                let sourcePt = childNodeWithName(arm2Source!)!.position
                
                armNode.position = sourcePt
                let destPt = bodyNode.convertPoint(leftNode.position, toNode: self)
                
                let xD = destPt.x - sourcePt.x
                let yD = destPt.y - sourcePt.y
                
                let dir:CGFloat = atan2(yD, xD)
                
                let len = hypot(yD, xD)
                let armLen = len+30
                
                armNode.zRotation = ( dir - ((90 + 45)/2)) - 0.05/// (CGFloat(M_PI) * 2) ) // CGFloat(M_PI_2)
                armNode.size.height = armLen
                let keepTen = 30/armLen
                armNode.anchorPoint = CGPoint(x: 0.5, y: 1-keepTen)
            }else{
                let armNode = childNodeWithName("arm2") as! SKSpriteNode
                let bodyNode = childNodeWithName("Body")!
                let leftNode = bodyNode.childNodeWithName("leftCircle")!
                armNode.position = leftNode.position
                armNode.size.height = 0
            }
            if arm3Source != nil{
                let armNode = childNodeWithName("arm3") as! SKSpriteNode
                let bodyNode = childNodeWithName("Body")!
                let rightNode = bodyNode.childNodeWithName("rightCircle")!
                let sourcePt = childNodeWithName(arm3Source!)!.position
                
                armNode.position = sourcePt
                let destPt = bodyNode.convertPoint(rightNode.position, toNode: self)
                
                let xD = destPt.x - sourcePt.x
                let yD = destPt.y - sourcePt.y
                
                let dir:CGFloat = atan2(yD, xD)
                
                let len = hypot(yD, xD)
                let armLen = len+30
                
                armNode.zRotation = ( dir - ((90 + 45)/2)) - 0.05/// (CGFloat(M_PI) * 2) ) // CGFloat(M_PI_2)
                armNode.size.height = armLen
                let keepTen = 30/armLen
                armNode.anchorPoint = CGPoint(x: 0.5, y: 1-keepTen)
            }else{
                let armNode = childNodeWithName("arm3") as! SKSpriteNode
                let bodyNode = childNodeWithName("Body")!
                let rightNode = bodyNode.childNodeWithName("rightCircle")!
                armNode.position = rightNode.position
                armNode.size.height = 0
            }
            
            for enemy in enemyArray{
                let offX = enemy.position.x - body.position.x
                let offY = enemy.position.y - body.position.y
                
                let distance = hypot(offX, offY)
                
                if distance < 80{
                    self.stopPresentation = true
                    self.signalDeath()
                    break
                }
            }
        }
    }
    
    var enemyArray = Array<SKSpriteNode>()
    let enemySchedule = [NSTimeInterval(10),NSTimeInterval(8),NSTimeInterval(5),NSTimeInterval(5),NSTimeInterval(5),NSTimeInterval(5),NSTimeInterval(3),NSTimeInterval(3),NSTimeInterval(3),NSTimeInterval(3),NSTimeInterval(3),NSTimeInterval(1)]
    var enemyProgress:Int = 0
    func beginEnemyInvasion(){
        if stopPresentation{
            return
        }
        let enemy = childNodeWithName("enemy") as! SKSpriteNode
        self.enemyArray.append(enemy)
    }
    var lastEnemyDate:NSDate = NSDate()
    func addNextEnemy(){
        if stopPresentation{
            return
        }
        if self.enemyArray.count < 25{
            let enemy = childNodeWithName("enemy") as! SKSpriteNode
            
            let newEnemy:SKSpriteNode = enemy.copy() as! SKSpriteNode
            let xOff:CGFloat = CGFloat(arc4random()%(2000))-1000
            let yOff:CGFloat = CGFloat(arc4random()%(2000))-1000
            newEnemy.position = CGPoint(x: xOff, y: yOff)
            self.addChild(newEnemy)
            self.enemyArray.append(newEnemy)
        }
    }
    
    
}
