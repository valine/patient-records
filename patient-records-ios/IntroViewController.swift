//
//  IntroViewController.swift
//  Patient Records
//
//  Created by Lukas Valine on 1/23/17.
//  Copyright © 2017 Lukas Valinevaline. All rights reserved.
//

import UIKit
import SpriteKit

class IntroViewController: UIViewController {
    
    
    var logoScene: SKScene?
    @IBOutlet weak var logoContainerView: LogoView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        logoScene = SKScene(fileNamed: "LargeLogoScene")!
        let skLogoView = logoContainerView as SKView
        skLogoView.allowsTransparency = true
        logoScene?.backgroundColor = .clear
        skLogoView.backgroundColor = UIColor.clear
        skLogoView.presentScene(logoScene)
        
        animateHeartWithDelay()
        
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector (self.touchGestureIcon(_:)))
        skLogoView.addGestureRecognizer(tapGesture)
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getStarted(_ sender: Any) {
        
            
//            splitViewController.delegate = self
//        splitViewController.preferredDisplayMode = .allVisible
       // self.dismiss(animated: true, completion: nil)
    }

    func touchGestureIcon(_ sender:UITapGestureRecognizer){
        animateHeart()
    }

    func animateHeart() {
        if #available(iOS 9.0, *) {
            let logoSprite = logoScene?.childNode(withName: "logo")
            logoSprite?.run(SKAction(named: "heart-beat")!)
            
        } else {
            // Fallback on earlier versions
        }
    }
    func animateHeartWithDelay() {
        if #available(iOS 9.0, *) {
            let logoSprite = logoScene?.childNode(withName: "logo")
            logoSprite?.run(SKAction(named: "heart-beat-delay")!)
            
        } else {
            // Fallback on earlier versions
        }
    }


}
