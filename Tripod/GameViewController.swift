//
//  GameViewController.swift
//  testingOutShapes
//
//  Created by NathanWSjoquist on 8/18/15.
//  Copyright (c) 2015 Nathan Sjoquist. All rights reserved.
//

import UIKit
import SpriteKit

extension SKNode {
    class func unarchiveFromFile(file : String) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as! GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.createScene()
    }
    
    func createScene(){
        print("create scene")
        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as! SKView
            //skView.showsFPS = true
            //skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            skView.presentScene(scene)
            
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "youDied", name: "YouDiedNote", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "youLived", name: "YouLivedNote", object: nil)
    }
    
    func youDied(){
        (self.view as! SKView).scene?.removeAllActions()
        (self.view as! SKView).scene?.removeAllChildren()
        (self.view as! SKView).scene?.removeFromParent()

        self.performSegueWithIdentifier("YouDiedSegue", sender: self)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    func youLived(){
        (self.view as! SKView).scene?.removeAllActions()
        (self.view as! SKView).scene?.removeAllChildren()
        (self.view as! SKView).scene?.removeFromParent()
        
        self.performSegueWithIdentifier("YouLivedSegue", sender: self)
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }


    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func unwind(sender:UIStoryboardSegue){
        performSegueWithIdentifier("unwindForStart", sender: self)
    }
}
